import AeroCloudCore
import SwiftUI

/// Палитра AeroCloud. Тёмная тема — единственная в v1.
public enum AeroColor {
    public static let background = Color(hex: 0x0A1628)
    public static let backgroundDeep = Color(hex: 0x050C18)
    public static let backgroundElevated = Color(hex: 0x0E1E36)

    public static let accentStart = Color(hex: 0x00D4FF)
    public static let accentEnd = Color(hex: 0x0066FF)

    public static let textPrimary = Color(hex: 0xF0F4FF)
    public static let textSecondary = Color(hex: 0xF0F4FF, opacity: 0.64)
    public static let textTertiary = Color(hex: 0xF0F4FF, opacity: 0.40)

    public static let stroke = Color.white.opacity(0.12)
    public static let strokeHighlight = Color.white.opacity(0.28)
    public static let glassTint = Color(hex: 0x0A1628, opacity: 0.55)
    public static let glassHighlight = Color.white.opacity(0.08)

    public static let accentGlow = Color(hex: 0x00D4FF, opacity: 0.55)
    public static let success = Color(hex: 0x3DDC97)
    public static let warning = Color(hex: 0xFFB020)
    public static let error = Color(hex: 0xFF5A6E)
    public static let like = Color(hex: 0xFF4D8D)

    public static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentStart, accentEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentStart.opacity(0.22),
                accentEnd.opacity(0.14),
                Color(hex: 0x071426, opacity: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static func sourceColor(_ source: MusicSource) -> Color {
        switch source {
        case .appleMusic: Color(hex: 0xFA2D48)
        case .spotify: Color(hex: 0x1ED760)
        case .soundCloud: Color(hex: 0xFF6B1A)
        case .youtubeMusic: Color(hex: 0xFF0033)
        case .deezer: Color(hex: 0xA238FF)
        case .lastFM: Color(hex: 0xD51007)
        case .local: Color(hex: 0x8AA4C8)
        case .demo: accentStart
        }
    }
}
