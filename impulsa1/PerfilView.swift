import SwiftUI

/// PANTALLA 6 — Perfil del usuario y cierre de sesión.
struct PerfilView: View {
    @EnvironmentObject var repo: Repositorio
    @State private var confirmarSalida = false
    @State private var notificaciones = true
    @State private var resumenSemanal = false

    var body: some View {
        let yo = repo.usuarioActual

        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    AvatarIniciales(texto: yo.iniciales, tamano: 88)
                        .accessibilityLabel("Foto de perfil")
                    Text(yo.nombre)
                        .font(.title2.bold())
                        .foregroundStyle(Color.impOnSurface)
                    Text("Asesor comercial")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .foregroundStyle(Color.impOnPrimaryContainer)
                        .background(Color.impPrimaryContainer, in: Capsule())
                }
                .padding(.top, 8)

                // Contacto
                VStack(spacing: 0) {
                    filaContacto("envelope.fill", yo.correo)
                    Divider().padding(.leading, 52)
                    filaContacto("phone.fill", yo.telefono.isEmpty ? "Sin teléfono registrado" : yo.telefono)
                }
                .tarjeta()

                // Estadísticas
                HStack(spacing: 0) {
                    estadistica("\(yo.ventas)", "Ventas")
                    Divider().frame(height: 40)
                    estadistica(yo.ingresos.aMoneda(), "Ingresos")
                }
                .padding(.vertical, 18)
                .tarjeta()

                // Preferencias
                VStack(spacing: 0) {
                    Toggle("Notificaciones de nuevas ventas", isOn: $notificaciones)
                        .padding(16)
                    Divider().padding(.leading, 16)
                    Toggle("Resumen semanal por correo", isOn: $resumenSemanal)
                        .padding(16)
                }
                .font(.subheadline)
                .foregroundStyle(Color.impOnSurface)
                .tarjeta()

                Button { confirmarSalida = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .foregroundStyle(Color.impError)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.impError, lineWidth: 1))
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(Color.impSurface)
        .navigationTitle("Perfil")
        .alert("Cerrar sesión", isPresented: $confirmarSalida) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                repo.cerrarSesion()     // vuelve al login solo
            }
        } message: {
            Text("¿Seguro que deseas salir de tu cuenta?")
        }
    }

    private func filaContacto(_ icono: String, _ texto: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icono)
                .foregroundStyle(Color.impPrimary)
                .frame(width: 24)
            Text(texto)
                .font(.subheadline)
                .foregroundStyle(Color.impOnSurface)
            Spacer()
        }
        .padding(16)
    }

    private func estadistica(_ valor: String, _ etiqueta: String) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.title3.bold())
                .foregroundStyle(Color.impOnSurface)
            Text(etiqueta.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.7)
                .foregroundStyle(Color.impOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }
}
