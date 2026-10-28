import SwiftUI

/// PANTALLA 4 — Desempeño: métricas del equipo y ranking de asesores.
struct DesempenoView: View {
    @EnvironmentObject var repo: Repositorio
    @State private var mensaje: String?

    var body: some View {
        let asesores = repo.asesores
        let ingresosEquipo = asesores.reduce(0) { $0 + $1.ingresos }
        let metaEquipo = asesores.reduce(0) { $0 + $1.meta }
        let cumplimiento = Int((ingresosEquipo / metaEquipo) * 100)
        let yo = repo.usuarioActual
        let ranking = asesores.sorted { $0.ingresos > $1.ingresos }

        ScrollView {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    metrica(icono: "trophy.fill", color: .impPrimary,
                            etiqueta: "Ingresos del equipo", valor: ingresosEquipo.aMoneda())
                    metrica(icono: "target", color: .impTertiary,
                            etiqueta: "Cumplimiento de meta", valor: "\(cumplimiento)%")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Mi avance personal")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.impOnSurface)
                    Text("\(yo.ventas) ventas cerradas · \(yo.ingresos.aMoneda())")
                        .font(.caption)
                        .foregroundStyle(Color.impOnSurfaceVariant)
                    BarraProgreso(valor: min(yo.porcentajeMeta, 100))
                        .padding(.top, 8)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tarjeta()

                TituloSeccion(texto: "Ranking del equipo").padding(.top, 6)

                ForEach(Array(ranking.enumerated()), id: \.element.id) { i, asesor in
                    Button {
                        mensaje = "\(asesor.nombre): \(asesor.ventas) ventas"
                    } label: {
                        FilaAsesor(posicion: i + 1, asesor: asesor, modo: .ranking)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 8)
        }
        .background(Color.impSurface)
        .navigationTitle("Desempeño")
        .toast($mensaje)
    }

    private func metrica(icono: String, color: Color, etiqueta: String, valor: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundStyle(color)
            Text(valor)
                .font(.title3.bold())
                .foregroundStyle(Color.impOnSurface)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(etiqueta)
                .font(.caption)
                .foregroundStyle(Color.impOnSurfaceVariant)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tarjeta()
    }
}
