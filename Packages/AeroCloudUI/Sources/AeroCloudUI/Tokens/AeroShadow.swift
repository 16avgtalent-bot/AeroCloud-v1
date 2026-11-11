import SwiftUI

public enum AeroShadow {
    public static let cardColor = Color.black.opacity(0.38)
    public static let cardRadius: CGFloat = 26
    public static let cardY: CGFloat = 14
    public static let glowColor = AeroColor.accentGlow
    public static let glowRadius: CGFloat = 18
}

public extension View {
    func aeroCardShadow() -> some View {
        shadow(
            color: AeroShadow.cardColor,
            radius: AeroShadow.cardRadius,
            x: 0,
            y: AeroShadow.cardY
        )
    }

    func aeroGlow(
        _ isActive: Bool,
        color: Color = AeroShadow.glowColor,
        radius: CGFloat = AeroShadow.glowRadius
    ) -> some View {
        shadow(
            color: isActive ? color : .clear,
            radius: isActive ? radius : 0,
            x: 0,
            y: 6
        )
        .animation(.easeOut(duration: 0.45), value: isActive)
    }
}
