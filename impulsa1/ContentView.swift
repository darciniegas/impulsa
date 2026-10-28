import SwiftUI

/// Raíz de la app: login o pantalla principal con barra inferior.
struct ContentView: View {
    @EnvironmentObject var repo: Repositorio

    var body: some View {
        Group {
            if repo.sesionIniciada {
                PrincipalView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: repo.sesionIniciada)
    }
}

/// Barra inferior con las 5 pestañas (equivale a BottomNavigationView + nav_graph).
struct PrincipalView: View {
    @EnvironmentObject var repo: Repositorio

    var body: some View {
        TabView(selection: $repo.pestana) {
            NavigationStack {
                InicioView().destinosImpulsa()
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            .tag(Pestana.inicio)

            NavigationStack {
                VentasView().destinosImpulsa()
            }
            .tabItem { Label("Ventas", systemImage: "list.bullet.rectangle.fill") }
            .tag(Pestana.ventas)

            NavigationStack {
                DesempenoView()
            }
            .tabItem { Label("Desempeño", systemImage: "chart.line.uptrend.xyaxis") }
            .tag(Pestana.desempeno)

            NavigationStack {
                ComisionesView()
            }
            .tabItem { Label("Comisiones", systemImage: "dollarsign.circle.fill") }
            .tag(Pestana.comisiones)

            NavigationStack {
                PerfilView()
            }
            .tabItem { Label("Perfil", systemImage: "person.fill") }
            .tag(Pestana.perfil)
        }
    }
}

extension View {
    /// Registra los destinos que se pueden apilar (detalle y registrar venta).
    func destinosImpulsa() -> some View {
        navigationDestination(for: Ruta.self) { ruta in
            switch ruta {
            case .detalle(let id): DetalleVentaView(ventaId: id)
            case .registrar:       RegistrarVentaView()
            }
        }
    }
}
