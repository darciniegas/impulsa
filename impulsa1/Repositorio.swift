import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Combine

/// Punto único de acceso a los datos.
///
///   Pantallas  ->  Repositorio  ->  SwiftData (teléfono)   <- fuente de lo que se ve
///                               ->  Firestore (nube)       <- respaldo y sincronización
///
/// Flujo: al guardar una venta se escribe primero en el teléfono y luego se envía a
/// Firestore (que la guarda en cola si no hay internet). Un "listener" de Firestore
/// devuelve los cambios de la nube y los copia a SwiftData.
final class Repositorio: ObservableObject {

    @Published var sesionIniciada = false
    @Published var pestana: Pestana = .inicio
    @Published var ventas: [Venta] = []

    // En las vistas previas de Xcode no hay GoogleService-Info.plist: se apaga Firebase.
    private let usaFirebase = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"

    private let contenedor: ModelContainer
    private let contexto: ModelContext
    private var uid = ""
    private var escuchaNube: ListenerRegistration?
    private var escuchaSesion: AuthStateDidChangeListenerHandle?

    // MARK: Equipo y catálogos

    private let equipo: [(id: String, nombre: String, correo: String, telefono: String, meta: Double)] = [
        ("a1", "Daniel", "daniel@impulsa", "", 50000),
    ]

    let formasDePago = ["Efectivo", "Transferencia", "Tarjeta de crédito", "Tarjeta débito", "Crédito a 30 días"]

    // MARK: Inicio

    init() {
        do {
            contenedor = try ModelContainer(for: VentaEntidad.self)
        } catch {
            contenedor = try! ModelContainer(
                for: VentaEntidad.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
        contexto = ModelContext(contenedor)

        guard usaFirebase else { return }
        if FirebaseApp.app() == nil { FirebaseApp.configure() }

        // Firebase recuerda la sesión: al abrir la app entra directo si ya inició antes.
        escuchaSesion = Auth.auth().addStateDidChangeListener { [weak self] _, usuario in
            DispatchQueue.main.async { self?.cambioDeSesion(uid: usuario?.uid) }
        }
    }

    // MARK: Sesión (Firebase Auth)

    func iniciarSesion(correo: String, clave: String) async throws {
        guard usaFirebase else {
            await MainActor.run { self.cambioDeSesion(uid: "vista-previa") }
            return
        }
        _ = try await Auth.auth().signIn(withEmail: Self.normalizar(correo), password: clave)
    }

    func recuperarClave(correo: String) async throws {
        guard usaFirebase else { return }
        try await Auth.auth().sendPasswordReset(withEmail: Self.normalizar(correo))
    }

    func cerrarSesion() {
        if usaFirebase { try? Auth.auth().signOut() } else { cambioDeSesion(uid: nil) }
    }

    /// Firebase exige correos con dominio completo. Si escriben "daniel@impulsa",
    /// se completa a "daniel@impulsa.co" (así debe crearse el usuario en la consola).
    static func normalizar(_ correo: String) -> String {
        let c = correo.trimmingCharacters(in: .whitespaces).lowercased()
        if let arroba = c.firstIndex(of: "@"), !c[arroba...].contains(".") { return c + ".co" }
        return c
    }

    static func mensaje(de error: Error) -> String {
        switch (error as NSError).code {
        case 17008:               return "El correo no es válido"
        case 17009, 17011, 17004: return "Correo o contraseña incorrectos"
        case 17020:               return "Sin conexión a internet"
        case 17010:               return "Demasiados intentos, espera un momento"
        default:                  return "No se pudo iniciar sesión"
        }
    }

    private func cambioDeSesion(uid nuevo: String?) {
        escuchaNube?.remove()
        escuchaNube = nil

        if let nuevo {
            uid = nuevo
            recargar()          // 1) muestra lo que ya hay en el teléfono
            escucharNube()      // 2) y empieza a sincronizar con Firestore
            pestana = .inicio
            sesionIniciada = true
        } else {
            uid = ""
            ventas = []
            sesionIniciada = false
        }
    }

    // MARK: Datos derivados

    var asesores: [Asesor] {
        equipo.map { e in
            let propias = ventasDe(e.nombre)
            let ingresos = propias.reduce(0) { $0 + $1.valor }
            return Asesor(id: e.id, nombre: e.nombre, correo: e.correo, telefono: e.telefono,
                          ventas: propias.count, ingresos: ingresos,
                          comision: Repositorio.calcularComision(ingresos), meta: e.meta)
        }
    }

    var usuarioActual: Asesor { asesores[0] }

    /// Esquema: hasta 20.000 → 5%, hasta 50.000 → 6,5%, más → 8%.
    static func calcularComision(_ total: Double) -> Double {
        if total <= 20000 { return total * 0.05 }
        if total <= 50000 { return total * 0.065 }
        return total * 0.08
    }

    func ventasDe(_ nombre: String) -> [Venta] { ventas.filter { $0.asesor == nombre } }
    func buscarVenta(_ id: String) -> Venta? { ventas.first { $0.id == id } }

    /// Código único (no depende del contador, así no choca entre dispositivos). Ej. V-3F9A2C
    func siguienteId() -> String { "V-" + String(UUID().uuidString.prefix(6)) }

    // MARK: Guardar

    func agregarVenta(_ venta: Venta) {
        contexto.insert(VentaEntidad(venta, uid: uid))
        try? contexto.save()
        recargar()

        guard usaFirebase, !uid.isEmpty else { return }
        // Funciona sin internet: Firestore la deja en cola y la sube después.
        coleccion().document(venta.id).setData(venta.datos)
    }

    // MARK: Base local (SwiftData)

    private func recargar() {
        let actual = uid
        let consulta = FetchDescriptor<VentaEntidad>(
            predicate: #Predicate<VentaEntidad> { $0.uid == actual },
            sortBy: [SortDescriptor(\.creadaEn, order: .reverse)])
        ventas = ((try? contexto.fetch(consulta)) ?? []).map { $0.modelo }
    }

    // MARK: Nube (Firestore)

    private struct CambioNube {
        let tipo: DocumentChangeType
        let venta: Venta
        let pendiente: Bool
    }

    /// usuarios/{uid}/ventas/{ventaId}
    private func coleccion() -> CollectionReference {
        Firestore.firestore().collection("usuarios").document(uid).collection("ventas")
    }

    private func escucharNube() {
        guard usaFirebase, !uid.isEmpty else { return }
        escuchaNube = coleccion().addSnapshotListener { [weak self] snap, _ in
            guard let snap else { return }
            let cambios: [CambioNube] = snap.documentChanges.compactMap { c in
                guard let venta = Venta(id: c.document.documentID, datos: c.document.data()) else { return nil }
                return CambioNube(tipo: c.type, venta: venta, pendiente: c.document.metadata.hasPendingWrites)
            }
            DispatchQueue.main.async { self?.aplicar(cambios) }
        }
    }

    /// Copia a SwiftData lo que llegó de la nube.
    private func aplicar(_ cambios: [CambioNube]) {
        for c in cambios {
            let id = c.venta.id
            var consulta = FetchDescriptor<VentaEntidad>(predicate: #Predicate<VentaEntidad> { $0.id == id })
            consulta.fetchLimit = 1
            let existente = try? contexto.fetch(consulta).first

            if c.tipo == .removed {
                if let existente { contexto.delete(existente) }
                continue
            }
            if let existente {
                existente.actualizar(con: c.venta)
                existente.sincronizado = !c.pendiente
            } else {
                let nueva = VentaEntidad(c.venta, uid: uid)
                nueva.sincronizado = !c.pendiente
                contexto.insert(nueva)
            }
        }
        try? contexto.save()
        recargar()
    }
}

// MARK: - Conversión Venta <-> documento de Firestore

extension Venta {
    var datos: [String: Any] {
        [
            "cliente": cliente,
            "concepto": concepto,
            "valor": valor,
            "asesor": asesor,
            "formaPago": formaPago,
            "fecha": fecha,
            "nota": nota,
            "creadaEn": Timestamp(date: creadaEn),
        ]
    }

    init?(id: String, datos: [String: Any]) {
        guard let cliente = datos["cliente"] as? String,
              let concepto = datos["concepto"] as? String,
              let valor = (datos["valor"] as? NSNumber)?.doubleValue,
              let asesor = datos["asesor"] as? String,
              let formaPago = datos["formaPago"] as? String,
              let fecha = datos["fecha"] as? String
        else { return nil }

        self.init(id: id, cliente: cliente, concepto: concepto, valor: valor, asesor: asesor,
                  formaPago: formaPago, fecha: fecha,
                  nota: datos["nota"] as? String ?? "",
                  creadaEn: (datos["creadaEn"] as? Timestamp)?.dateValue() ?? Date())
    }
}
