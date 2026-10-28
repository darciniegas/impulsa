import Foundation
import SwiftData

/// Tabla local (SwiftData) donde se guardan las ventas en el teléfono.
/// Cada fila pertenece a un usuario (uid de Firebase) para no mezclar cuentas.
@Model
final class VentaEntidad {
    @Attribute(.unique) var id: String
    var uid: String
    var cliente: String
    var concepto: String
    var valor: Double
    var asesor: String
    var formaPago: String
    var fecha: String
    var nota: String
    var creadaEn: Date
    /// false = aún no confirmada por el servidor (se subirá sola al volver la conexión).
    var sincronizado: Bool

    init(_ v: Venta, uid: String) {
        self.id = v.id
        self.uid = uid
        self.cliente = v.cliente
        self.concepto = v.concepto
        self.valor = v.valor
        self.asesor = v.asesor
        self.formaPago = v.formaPago
        self.fecha = v.fecha
        self.nota = v.nota
        self.creadaEn = v.creadaEn
        self.sincronizado = false
    }

    func actualizar(con v: Venta) {
        cliente = v.cliente
        concepto = v.concepto
        valor = v.valor
        asesor = v.asesor
        formaPago = v.formaPago
        fecha = v.fecha
        nota = v.nota
        creadaEn = v.creadaEn
    }

    var modelo: Venta {
        Venta(id: id, cliente: cliente, concepto: concepto, valor: valor, asesor: asesor,
              formaPago: formaPago, fecha: fecha, nota: nota, creadaEn: creadaEn)
    }
}
