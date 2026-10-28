import SwiftUI

/// PANTALLA 2 — Dashboard: KPIs, avance de meta y ventas recientes.
struct InicioView: View {
    @EnvironmentObject var repo: Repositorio
    @State private var periodo = "Mes"

    var body: some View {
        let usuario = repo.usuarioActual
        let recientes = Array(repo.ventasDe(usuario.nombre).prefix(3))

        ScrollView {
            VStack(spacing: 0) {
                encabezado(usuario)
                kpis(usuario)
                    .padding(.horizontal, 16)
                    .padding(.top, -24)

                VStack(spacing: 14) {
                    avanceMeta(usuario)

                    NavigationLink(value: Ruta.registrar) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Registrar nueva venta").font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .foregroundStyle(Color.impOnPrimary)
                        .background(Color.impPrimary, in: RoundedRectangle(cornerRadius: 20))
                    }

                    HStack {
                        Text("Ventas recientes")
                            .font(.headline)
                            .foregroundStyle(Color.impOnSurface)
                        Spacer()
                        Button("Ver todas") { repo.pestana = .ventas }
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.top, 6)

                    if recientes.isEmpty {
                        EstadoVacio(icono: "tray", titulo: "Aún no hay ventas",
                                    detalle: "Registra tu primera venta con el botón de arriba.")
                    }

                    ForEach(recientes) { venta in
                        NavigationLink(value: Ruta.detalle(venta.id)) {
                            FilaVenta(venta: venta)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 12) {
                        accesoRapido(icono: "chart.line.uptrend.xyaxis", color: .impPrimary,
                                     titulo: "Mi desempeño", detalle: "Ver métricas") {
                            repo.pestana = .desempeno
                        }
                        accesoRapido(icono: "dollarsign.circle.fill", color: .impTertiary,
                                     titulo: "Comisiones", detalle: "Ver detalle") {
                            repo.pestana = .comisiones
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color.impSurface.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Piezas

    private func encabezado(_ usuario: Asesor) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BIENVENIDO")
                        .font(.caption2.weight(.medium))
                        .tracking(1.2)
                        .foregroundStyle(Color(hex: 0xB8EFE7))
                    Text(usuario.nombre)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                AvatarIniciales(texto: usuario.iniciales, tamano: 48)
                    .accessibilityLabel("Foto de perfil")
            }

            HStack(spacing: 8) {
                ForEach(["Hoy", "Semana", "Mes"], id: \.self) { p in
                    Button { periodo = p } label: {
                        Text(p)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .foregroundStyle(periodo == p ? Color.impOnPrimaryContainer : .white)
                            .background(periodo == p ? Color.impPrimaryContainer : .clear, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.6), lineWidth: periodo == p ? 0 : 1))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(bottomLeadingRadius: 28, bottomTrailingRadius: 28)
                .fill(LinearGradient(colors: [.impPrimary, .impTertiary],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea(edges: .top)
        }
    }

    private func kpis(_ u: Asesor) -> some View {
        HStack(spacing: 0) {
            kpi(u.ingresos.aMoneda(), "Ventas")
            Divider().frame(height: 40)
            kpi(u.comision.aMoneda(), "Comisión")
            Divider().frame(height: 40)
            kpi("\(u.porcentajeMeta)%", "Meta")
        }
        .padding(.vertical, 18)
        .tarjeta()
    }

    private func kpi(_ valor: String, _ etiqueta: String) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.impOnSurface)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(etiqueta.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.7)
                .foregroundStyle(Color.impOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    private func avanceMeta(_ u: Asesor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Avance de meta — Agosto")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.impOnSurface)
                Spacer()
                Text("\(u.porcentajeMeta)%")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(Color.impOnPrimaryContainer)
                    .background(Color.impPrimaryContainer, in: Capsule())
            }
            Text("\(u.ingresos.aMoneda()) de \(u.meta.aMoneda())")
                .font(.caption)
                .foregroundStyle(Color.impOnSurfaceVariant)
            BarraProgreso(valor: min(u.porcentajeMeta, 100))
                .padding(.top, 10)
        }
        .padding(18)
        .tarjeta()
    }

    private func accesoRapido(icono: String, color: Color, titulo: String,
                              detalle: String, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            VStack(alignment: .leading, spacing: 2) {
                Image(systemName: icono)
                    .font(.title3)
                    .foregroundStyle(color)
                    .padding(.bottom, 8)
                Text(titulo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.impOnSurface)
                Text(detalle)
                    .font(.caption)
                    .foregroundStyle(Color.impOnSurfaceVariant)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tarjeta()
        }
        .buttonStyle(.plain)
    }
}
