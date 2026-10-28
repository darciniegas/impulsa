import SwiftUI

/// PANTALLA 3 — Listado de ventas con buscador y filtros por forma de pago.
struct VentasView: View {
    @EnvironmentObject var repo: Repositorio

    @State private var busqueda = ""
    @State private var filtro = "Todas"
    private let filtros = ["Todas", "Transferencia", "Efectivo", "Tarjeta"]

    private var resultado: [Venta] {
        repo.ventas.filter { v in
            let texto = busqueda.trimmingCharacters(in: .whitespaces)
            let coincideTexto = texto.isEmpty
                || v.cliente.localizedCaseInsensitiveContains(texto)
                || v.concepto.localizedCaseInsensitiveContains(texto)
            let coincidePago = filtro == "Todas"
                || v.formaPago.localizedCaseInsensitiveContains(filtro)
            return coincideTexto && coincidePago
        }
    }

    var body: some View {
        let lista = resultado

        ScrollView {
            LazyVStack(spacing: 10) {
                // Buscador
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(Color.impOutline)
                    TextField("Buscar cliente o concepto", text: $busqueda)
                        .autocorrectionDisabled()
                    if !busqueda.isEmpty {
                        Button { busqueda = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(Color.impOutline)
                        }
                    }
                }
                .padding(14)
                .background(Color.impContainer, in: Capsule())

                // Filtros
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filtros, id: \.self) { f in
                            Button { filtro = f } label: {
                                HStack(spacing: 4) {
                                    if filtro == f { Image(systemName: "checkmark").font(.caption) }
                                    Text(f).font(.subheadline.weight(.medium))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(filtro == f ? Color.impOnPrimaryContainer : Color.impOnSurfaceVariant)
                                .background(filtro == f ? Color.impSecondaryContainer : .clear, in: RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.impOutlineVariant, lineWidth: filtro == f ? 0 : 1))
                            }
                        }
                    }
                }

                Text("\(lista.count) ventas · \(lista.reduce(0) { $0 + $1.valor }.aMoneda())")
                    .font(.footnote)
                    .foregroundStyle(Color.impOnSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)

                if lista.isEmpty {
                    EstadoVacio(icono: "tray",
                                titulo: repo.ventas.isEmpty ? "Aún no hay ventas" : "Sin resultados",
                                detalle: repo.ventas.isEmpty
                                    ? "Toca «Nueva venta» para registrar la primera."
                                    : "Prueba con otra búsqueda o filtro.")
                }

                ForEach(lista) { venta in
                    NavigationLink(value: Ruta.detalle(venta.id)) {
                        FilaVenta(venta: venta)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 90)
        }
        .background(Color.impSurface)
        .navigationTitle("Ventas")
        .overlay(alignment: .bottomTrailing) {
            NavigationLink(value: Ruta.registrar) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Nueva venta").fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .frame(height: 56)
                .foregroundStyle(Color.impOnPrimaryContainer)
                .background(Color.impPrimaryContainer, in: RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
            }
            .padding(16)
        }
    }
}
