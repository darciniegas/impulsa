import SwiftUI

/// PANTALLA 7 — Formulario para registrar una venta nueva.
struct RegistrarVentaView: View {
    @EnvironmentObject var repo: Repositorio
    @Environment(\.dismiss) private var dismiss

    @State private var cliente = ""
    @State private var concepto = ""
    @State private var valor = ""
    @State private var formaPago = ""
    @State private var fecha = Date()
    @State private var nota = ""

    @State private var errCliente: String?
    @State private var errConcepto: String?
    @State private var errValor: String?
    @State private var errPago: String?
    @State private var mensaje: String?

    private static let formato: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_CO")
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CampoTexto(titulo: "Cliente *", texto: $cliente, error: errCliente)
                CampoTexto(titulo: "Concepto o producto *", texto: $concepto, error: errConcepto)
                CampoTexto(titulo: "Valor de la venta *", texto: $valor,
                           error: errValor, teclado: .decimalPad)

                // Forma de pago (desplegable)
                VStack(alignment: .leading, spacing: 4) {
                    Menu {
                        ForEach(repo.formasDePago, id: \.self) { f in
                            Button(f) { formaPago = f }
                        }
                    } label: {
                        HStack {
                            Text(formaPago.isEmpty ? "Forma de pago *" : formaPago)
                                .foregroundStyle(formaPago.isEmpty ? Color.impOutline : Color.impOnSurface)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(Color.impOutline)
                        }
                        .padding(14)
                        .background(Color.impCard, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(errPago == nil ? Color.impOutline : Color.impError,
                                    lineWidth: errPago == nil ? 1 : 2))
                    }
                    if let errPago {
                        Text(errPago).font(.caption).foregroundStyle(Color.impError).padding(.leading, 4)
                    }
                }

                // Fecha
                HStack {
                    Text("Fecha").foregroundStyle(Color.impOnSurface)
                    Spacer()
                    DatePicker("", selection: $fecha, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "es_CO"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.impCard, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.impOutline, lineWidth: 1))

                CampoTexto(titulo: "Nota (opcional)", texto: $nota, maxLineas: 4)

                BotonPrincipal(titulo: "Guardar venta", icono: "checkmark", alto: 54, accion: guardar)
                    .padding(.top, 6)

                Button("Cancelar") { dismiss() }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.impSurface)
        .navigationTitle("Registrar venta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toast($mensaje)
    }

    private func guardar() {
        let c = cliente.trimmingCharacters(in: .whitespaces)
        let k = concepto.trimmingCharacters(in: .whitespaces)
        let valorTexto = valor.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        let numero = Double(valorTexto)
        var ok = true

        if c.isEmpty { errCliente = "Ingresa el cliente"; ok = false } else { errCliente = nil }
        if k.isEmpty { errConcepto = "Ingresa el concepto"; ok = false } else { errConcepto = nil }

        if valorTexto.isEmpty {
            errValor = "Ingresa el valor"; ok = false
        } else if (numero ?? 0) <= 0 {
            errValor = "Valor inválido"; ok = false
        } else {
            errValor = nil
        }

        if formaPago.isEmpty { errPago = "Selecciona la forma de pago"; ok = false } else { errPago = nil }

        guard ok, let numero else {
            mensaje = "Revisa los campos marcados"
            return
        }

        repo.agregarVenta(Venta(
            id: repo.siguienteId(),
            cliente: c,
            concepto: k,
            valor: numero,
            asesor: repo.usuarioActual.nombre,
            formaPago: formaPago,
            fecha: Self.formato.string(from: fecha),
            nota: nota.trimmingCharacters(in: .whitespacesAndNewlines)
        ))

        mensaje = "¡Venta registrada correctamente!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
    }
}
