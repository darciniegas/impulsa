import SwiftUI
import UIKit

// MARK: - Colores (Material 3, semilla #0D9488, modo claro y oscuro)

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: UInt32) { self.init(UIColor(hex: hex)) }

    /// Color que cambia solo entre modo claro y oscuro.
    init(claro: UInt32, oscuro: UInt32) {
        self.init(UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? oscuro : claro)
        })
    }

    static let impPrimary              = Color(claro: 0x046A61, oscuro: 0x7CD6CA)
    static let impOnPrimary            = Color(claro: 0xFFFFFF, oscuro: 0x003732)
    static let impPrimaryContainer     = Color(claro: 0x98F3E6, oscuro: 0x025049)
    static let impOnPrimaryContainer   = Color(claro: 0x00201D, oscuro: 0x98F3E6)
    static let impSecondaryContainer   = Color(claro: 0xC8E9E4, oscuro: 0x2F4C48)
    static let impTertiary             = Color(claro: 0x3B6378, oscuro: 0xA4CCE4)
    static let impTertiaryContainer    = Color(claro: 0xC3E8FE, oscuro: 0x214B60)
    static let impError                = Color(claro: 0xC00013, oscuro: 0xFFB4A5)
    static let impSurface              = Color(claro: 0xF6FEFC, oscuro: 0x171D1C)
    static let impOnSurface            = Color(claro: 0x171D1C, oscuro: 0xDCE4E3)
    static let impOnSurfaceVariant     = Color(claro: 0x3A4A47, oscuro: 0xB8CAC7)
    static let impOutline              = Color(claro: 0x697B78, oscuro: 0x829491)
    static let impOutlineVariant       = Color(claro: 0xB8CAC7, oscuro: 0x3A4A47)
    static let impCard                 = Color(claro: 0xFFFFFF, oscuro: 0x1B2120)
    static let impContainer            = Color(claro: 0xE7F0EE, oscuro: 0x252B2A)
    static let impSuccess              = Color(claro: 0x1B6B4B, oscuro: 0x8DD6B0)
    static let impSuccessContainer     = Color(claro: 0xB7F2D3, oscuro: 0x1B6B4B)
}

// MARK: - Estilos reutilizables

/// Tarjeta redondeada (equivale a "TarjetaImpulsa" en Android).
struct TarjetaImpulsa: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.impCard, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
    }
}

extension View {
    func tarjeta() -> some View { modifier(TarjetaImpulsa()) }
}

/// Círculo con las iniciales del asesor.
struct AvatarIniciales: View {
    let texto: String
    var tamano: CGFloat = 40

    var body: some View {
        Text(texto)
            .font(.system(size: tamano * 0.38, weight: .bold))
            .foregroundStyle(Color.impOnPrimaryContainer)
            .frame(width: tamano, height: tamano)
            .background(Color.impPrimaryContainer, in: Circle())
    }
}

/// Etiqueta tipo "chip" no interactiva.
struct ChipEtiqueta: View {
    let texto: String
    var body: some View {
        Text(texto)
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.impOnSurfaceVariant)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(Capsule().stroke(Color.impOutlineVariant, lineWidth: 1))
    }
}

/// Barra de progreso redondeada (0-100).
struct BarraProgreso: View {
    let valor: Int
    var alto: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.impPrimaryContainer.opacity(0.6))
                Capsule()
                    .fill(Color.impPrimary)
                    .frame(width: geo.size.width * CGFloat(min(max(valor, 0), 100)) / 100)
            }
        }
        .frame(height: alto)
        .animation(.easeOut(duration: 0.6), value: valor)
    }
}

/// Botón principal relleno.
struct BotonPrincipal: View {
    let titulo: String
    var icono: String? = nil
    var alto: CGFloat = 52
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            HStack(spacing: 8) {
                if let icono { Image(systemName: icono) }
                Text(titulo).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: alto)
            .foregroundStyle(Color.impOnPrimary)
            .background(Color.impPrimary, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}
