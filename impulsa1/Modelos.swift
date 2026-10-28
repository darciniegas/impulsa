import SwiftUI

// MARK: - Modelos

/// Una venta registrada por un asesor.
struct Venta: Identifiable, Hashable {
    let id: String
    var cliente: String
    var concepto: String
    var valor: Double
    var asesor: String
    var formaPago: String
    var fecha: String
    var nota: String = ""
    var creadaEn: Date = Date()
}

/// Un asesor comercial.
struct Asesor: Identifiable, Hashable {
    let id: String
    let nombre: String
    let correo: String
    let telefono: String
    let ventas: Int
    let ingresos: Double
    let comision: Double
    let meta: Double

    /// Iniciales para el avatar, ej. "Ana García" -> "AG"
    var iniciales: String {
        nombre.split(separator: " ")
            .compactMap { $0.first.map { String($0).uppercased() } }
            .prefix(2)
            .joined()
    }

    /// Porcentaje de avance de la meta (tope 999).
    var porcentajeMeta: Int {
        min(Int((ingresos / meta) * 100), 999)
    }
}

// MARK: - Formato de moneda

extension Double {
    /// 54200.0 -> "$ 54.200"
    func aMoneda() -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "es_CO")
        nf.maximumFractionDigits = 0
        return "$ " + (nf.string(from: NSNumber(value: self)) ?? "\(Int(self))")
    }
}

// MARK: - Rutas de navegación

/// Destinos que se apilan encima de cada pestaña (equivale al nav_graph.xml).
enum Ruta: Hashable {
    case detalle(String)     // argumento: ventaId
    case registrar
}

enum Pestana: Hashable {
    case inicio, ventas, desempeno, comisiones, perfil
}
