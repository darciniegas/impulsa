import SwiftUI

/// Las tres barras del logo de Impulsa (mismo dibujo que el ícono Android).
struct BarrasLogo: Shape {
    func path(in rect: CGRect) -> Path {
        // Dibujo base de 40 x 42 unidades.
        let ancho: CGFloat = 40, alto: CGFloat = 42
        let kx = rect.width / ancho, ky = rect.height / alto
        let barras: [CGRect] = [
            CGRect(x: 0,  y: 6,  width: 10, height: 36),
            CGRect(x: 15, y: 0,  width: 10, height: 42),
            CGRect(x: 30, y: 14, width: 10, height: 28),
        ]
        var p = Path()
        for b in barras {
            p.addRect(CGRect(x: rect.minX + b.minX * kx, y: rect.minY + b.minY * ky,
                             width: b.width * kx, height: b.height * ky))
        }
        return p
    }
}

/// Logo completo: cuadrado redondeado verde azulado con las barras en blanco.
struct LogoImpulsa: View {
    var tamano: CGFloat = 84

    var body: some View {
        // Si agregaste tu propio logo al catálogo con el nombre "LogoPropio", se usa ese.
        if UIImage(named: "LogoPropio") != nil {
            Image("LogoPropio")
                .resizable()
                .scaledToFit()
                .frame(width: tamano, height: tamano)
                .clipShape(RoundedRectangle(cornerRadius: tamano * 0.22, style: .continuous))
                .accessibilityLabel("Logotipo de Impulsa")
        } else {
            logoDibujado
        }
    }

    private var logoDibujado: some View {
        ZStack {
            RoundedRectangle(cornerRadius: tamano * 0.31, style: .continuous)
                .fill(Color.impPrimary)
            BarrasLogo()
                .fill(Color.impOnPrimary)
                .aspectRatio(40.0 / 42.0, contentMode: .fit)
                .frame(height: tamano * 0.50)
        }
        .frame(width: tamano, height: tamano)
        .accessibilityLabel("Logotipo de Impulsa")
    }
}

#Preview {
    HStack(spacing: 24) {
        LogoImpulsa(tamano: 96)
        LogoImpulsa(tamano: 56)
    }
    .padding()
}
