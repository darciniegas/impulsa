import SwiftUI

/// PANTALLA 1 — Inicio de sesión con Firebase Authentication.
struct LoginView: View {
    @EnvironmentObject var repo: Repositorio

    @State private var correo = ""
    @State private var password = ""
    @State private var errorCorreo: String?
    @State private var errorPassword: String?
    @State private var cargando = false
    @State private var mensaje: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                LogoImpulsa(tamano: 84)
                    .padding(.top, 60)

                VStack(spacing: 4) {
                    Text("Impulsa")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.impOnSurface)
                    Text("Gestiona tus ventas y comisiones")
                        .font(.subheadline)
                        .foregroundStyle(Color.impOnSurfaceVariant)
                }
                .padding(.bottom, 12)

                CampoTexto(titulo: "Correo electrónico", texto: $correo,
                           error: errorCorreo, teclado: .emailAddress)
                CampoTexto(titulo: "Contraseña", texto: $password,
                           error: errorPassword, seguro: true)

                BotonPrincipal(titulo: cargando ? "Ingresando…" : "Iniciar sesión", alto: 54) {
                    Task { await entrar() }
                }
                .disabled(cargando)
                .opacity(cargando ? 0.6 : 1)
                .padding(.top, 8)

                Button("¿Olvidaste tu contraseña?") {
                    Task { await recuperar() }
                }
                .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.impSurface.ignoresSafeArea())
        .toast($mensaje)
    }

    @MainActor
    private func entrar() async {
        let c = correo.trimmingCharacters(in: .whitespaces)
        errorCorreo = c.isEmpty ? "Ingresa tu correo" : nil
        errorPassword = password.isEmpty ? "Ingresa tu contraseña" : nil
        guard errorCorreo == nil, errorPassword == nil else { return }

        cargando = true
        defer { cargando = false }
        do {
            try await repo.iniciarSesion(correo: c, clave: password)   // al entrar, ContentView cambia sola
        } catch {
            errorPassword = Repositorio.mensaje(de: error)
        }
    }

    @MainActor
    private func recuperar() async {
        let c = correo.trimmingCharacters(in: .whitespaces)
        guard !c.isEmpty else { mensaje = "Escribe tu correo primero"; return }
        do {
            try await repo.recuperarClave(correo: c)
            mensaje = "Te enviamos un correo de recuperación"
        } catch {
            mensaje = Repositorio.mensaje(de: error)
        }
    }
}
