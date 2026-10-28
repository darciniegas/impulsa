import SwiftUI

// MARK: - Campo de texto con borde y mensaje de error (equivale a TextInputLayout)

struct CampoTexto: View {
    let titulo: String
    @Binding var texto: String
    var error: String? = nil
    var teclado: UIKeyboardType = .default
    var seguro = false
    var maxLineas = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if seguro {
                    SecureField(titulo, text: $texto)
                } else {
                    TextField(titulo, text: $texto, axis: .vertical)
                        .lineLimit(1...maxLineas)
                        .keyboardType(teclado)
                }
            }
            .textInputAutocapitalization(teclado == .emailAddress ? .never : .sentences)
            .autocorrectionDisabled(teclado == .emailAddress || seguro)
            .padding(14)
            .background(Color.impCard, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error == nil ? Color.impOutline : Color.impError, lineWidth: error == nil ? 1 : 2)
            )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.impError)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Mensaje temporal (equivale al Snackbar)

struct ToastModifier: ViewModifier {
    @Binding var mensaje: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let texto = mensaje {
                Text(texto)
                    .font(.subheadline)
                    .foregroundStyle(Color(claro: 0xEAF2F1, oscuro: 0x2B3231))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(claro: 0x2B3231, oscuro: 0xEAF2F1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: texto) {
                        try? await Task.sleep(nanoseconds: 2_500_000_000)
                        mensaje = nil
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: mensaje)
    }
}

extension View {
    func toast(_ mensaje: Binding<String?>) -> some View {
        modifier(ToastModifier(mensaje: mensaje))
    }
}

// MARK: - Fila de venta (item_venta.xml)

struct FilaVenta: View {
    let venta: Venta

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(venta.concepto)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.impOnSurface)
                    .lineLimit(1)
                Text(venta.cliente)
                    .font(.caption)
                    .foregroundStyle(Color.impOnSurfaceVariant)
                    .lineLimit(1)
                Text("\(venta.fecha) · \(venta.asesor)")
                    .font(.caption2)
                    .foregroundStyle(Color.impOutline)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(venta.valor.aMoneda())
                    .font(.headline)
                    .foregroundStyle(Color.impPrimary)
                ChipEtiqueta(texto: venta.formaPago)
            }
        }
        .padding(14)
        .tarjeta()
    }
}

// MARK: - Fila de asesor (item_asesor.xml) — se usa en Desempeño y Comisiones

enum ModoAsesor { case ranking, comision }

struct FilaAsesor: View {
    let posicion: Int
    let asesor: Asesor
    let modo: ModoAsesor

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("\(posicion)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.impOutline)
                    .frame(width: 22, alignment: .leading)
                AvatarIniciales(texto: asesor.iniciales)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asesor.nombre)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.impOnSurface)
                    Text(subtitulo)
                        .font(.caption)
                        .foregroundStyle(Color.impOnSurfaceVariant)
                }
                Spacer()
                Text(valorDerecha)
                    .font(.headline)
                    .foregroundStyle(Color.impPrimary)
            }
            BarraProgreso(valor: min(asesor.porcentajeMeta, 100), alto: 6)
        }
        .padding(14)
        .tarjeta()
    }

    private var subtitulo: String {
        switch modo {
        case .ranking:  return "\(asesor.ventas) ventas · meta \(asesor.porcentajeMeta)%"
        case .comision: return "Sobre \(asesor.ingresos.aMoneda()) vendidos"
        }
    }

    private var valorDerecha: String {
        modo == .ranking ? asesor.ingresos.aMoneda() : asesor.comision.aMoneda()
    }
}

// MARK: - Título de sección

struct TituloSeccion: View {
    let texto: String
    var body: some View {
        Text(texto)
            .font(.headline)
            .foregroundStyle(Color.impOnSurface)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Mensaje cuando no hay datos

struct EstadoVacio: View {
    let icono: String
    let titulo: String
    let detalle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono)
                .font(.system(size: 34))
                .foregroundStyle(Color.impOutline)
            Text(titulo)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.impOnSurface)
            Text(detalle)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.impOnSurfaceVariant)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .tarjeta()
    }
}
