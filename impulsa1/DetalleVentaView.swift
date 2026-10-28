import SwiftUI

/// PANTALLA 8 — Detalle de una venta (recibe el argumento ventaId).
struct DetalleVentaView: View {
    @EnvironmentObject var repo: Repositorio
    @Environment(\.dismiss) private var dismiss
    let ventaId: String

    var body: some View {
        ScrollView {
            if let venta = repo.buscarVenta(ventaId) {
                VStack(spacing: 14) {
                    // Cabecera
                    VStack(spacing: 8) {
                        Text(venta.id)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.impOnSurfaceVariant)
                        Text(venta.valor.aMoneda())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color.impPrimary)
                        Label("Venta confirmada", systemImage: "checkmark.circle.fill")
                            .font(.footnote.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundStyle(Color.impSuccess)
                            .background(Color.impSuccessContainer, in: Capsule())
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .tarjeta()

                    // Datos
                    VStack(alignment: .leading, spacing: 16) {
                        dato("Cliente", venta.cliente)
                        dato("Concepto", venta.concepto)
                        dato("Asesor responsable", venta.asesor)
                        HStack(alignment: .top) {
                            dato("Forma de pago", venta.formaPago)
                            Spacer()
                            dato("Fecha", venta.fecha)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tarjeta()

                    if !venta.nota.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NOTA")
                                .font(.caption2.weight(.medium))
                                .tracking(0.7)
                                .foregroundStyle(Color.impOnSurfaceVariant)
                            Text(venta.nota)
                                .font(.subheadline)
                                .foregroundStyle(Color.impOnSurface)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tarjeta()
                    }

                    Button("Volver") { dismiss() }
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.impOutline, lineWidth: 1))
                        .padding(.top, 4)
                }
                .padding(16)
            } else {
                Text("Venta no encontrada")
                    .foregroundStyle(Color.impOnSurfaceVariant)
                    .padding(40)
            }
        }
        .background(Color.impSurface)
        .navigationTitle("Detalle de venta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func dato(_ etiqueta: String, _ valor: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(etiqueta.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.7)
                .foregroundStyle(Color.impOnSurfaceVariant)
            Text(valor)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.impOnSurface)
        }
    }
}
