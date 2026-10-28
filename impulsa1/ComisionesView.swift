import SwiftUI

/// PANTALLA 5 — Comisiones del usuario y del equipo.
struct ComisionesView: View {
    @EnvironmentObject var repo: Repositorio
    @State private var mensaje: String?

    var body: some View {
        let yo = repo.usuarioActual
        let porcentaje = yo.ingresos > 0 ? (yo.comision / yo.ingresos) * 100 : 0
        let porComision = repo.asesores.sorted { $0.comision > $1.comision }
        let pctTexto = String(format: "%.1f", locale: Locale(identifier: "es_CO"), porcentaje)

        ScrollView {
            VStack(spacing: 14) {
                // Tarjeta principal
                VStack(alignment: .leading, spacing: 6) {
                    Text("COMISIÓN ESTIMADA · AGOSTO")
                        .font(.caption.weight(.medium))
                        .tracking(1)
                        .foregroundStyle(Color(hex: 0xB8EFE7))
                    Text(yo.comision.aMoneda())
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(pctTexto)% sobre \(yo.ingresos.aMoneda()) en ventas")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    Button {
                        mensaje = "Solicitud enviada a administración"
                    } label: {
                        Text("Solicitar liquidación")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(Color.impOnPrimaryContainer)
                            .background(Color.impPrimaryContainer, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 14)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [.impPrimary, .impTertiary],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 24)
                )

                // Esquema
                VStack(alignment: .leading, spacing: 8) {
                    Text("Esquema de comisiones")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.impOnSurface)
                    ForEach([
                        "• Hasta $ 20.000 en ventas → 5%",
                        "• De $ 20.001 a $ 50.000 → 6,5%",
                        "• Más de $ 50.000 → 8%",
                    ], id: \.self) { linea in
                        Text(linea)
                            .font(.footnote)
                            .foregroundStyle(Color.impOnSurfaceVariant)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tarjeta()

                TituloSeccion(texto: "Comisiones del equipo").padding(.top, 6)

                ForEach(Array(porComision.enumerated()), id: \.element.id) { i, asesor in
                    Button {
                        mensaje = "Comisión de \(asesor.nombre): \(asesor.comision.aMoneda())"
                    } label: {
                        FilaAsesor(posicion: i + 1, asesor: asesor, modo: .comision)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(Color.impSurface)
        .navigationTitle("Comisiones")
        .toast($mensaje)
    }
}
