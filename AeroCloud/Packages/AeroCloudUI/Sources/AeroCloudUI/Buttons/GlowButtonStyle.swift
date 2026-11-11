import SwiftUI

/// Круглая glass-кнопка для иконок: мини-плеер, плеер, тулбар.
public struct GlowButtonStyle: ButtonStyle {
    public var size: CGFloat
    public var tint: Color
    public var glow: Color

    public init(
        size: CGFloat = 44,
        tint: Color = AeroColor.glassTint,
        glow: Color = AeroColor.accentGlow
    ) {
        self.size = size
        self.tint = tint
        self.glow = glow
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aeroFont(.headline)
            .foregroundStyle(AeroColor.textPrimary)
            .frame(width: size, height: size)
            .glassEffect(.regular.tint(tint).interactive(), in: .circle)
            .overlay {
                Circle()
                    .strokeBorder(AeroColor.stroke, lineWidth: 0.75)
                    .allowsHitTesting(false)
            }
            .shadow(
                color: configuration.isPressed ? glow.opacity(0.55) : .clear,
                radius: configuration.isPressed ? 16 : 0,
                x: 0,
                y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(AeroMotion.press, value: configuration.isPressed)
    }
}
