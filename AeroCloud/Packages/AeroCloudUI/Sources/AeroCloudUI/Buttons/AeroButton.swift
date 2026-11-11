import SwiftUI

public enum AeroButtonKind: Sendable {
    case primary
    case secondary
    case ghost
    case destructive
    case icon
}

/// Стиль кнопок AeroCloud. Все варианты имеют press-масштаб,
/// glow при нажатии и поддержку Dynamic Type.
public struct AeroButtonStyle: ButtonStyle {
    private let kind: AeroButtonKind
    private let fullWidth: Bool
    private let isEnabled: Bool
    private let reduceMotion: Bool

    public init(
        kind: AeroButtonKind = .primary,
        fullWidth: Bool = false,
        isEnabled: Bool = true,
        reduceMotion: Bool = false
    ) {
        self.kind = kind
        self.fullWidth = fullWidth
        self.isEnabled = isEnabled
        self.reduceMotion = reduceMotion
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aeroFont(.headline)
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, kind == .icon ? 0 : AeroSpacing.lg)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(width: kind == .icon ? 44 : nil)
            .frame(height: kind == .icon ? 44 : 52)
            .background { background }
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(borderColor, lineWidth: 1)
            }
            .shadow(
                color: configuration.isPressed ? glowColor.opacity(0.55) : .clear,
                radius: configuration.isPressed ? 18 : 0,
                x: 0,
                y: 8
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(AeroMotion.press, value: configuration.isPressed)
            .opacity(isEnabled ? 1 : 0.45)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: kind == .icon ? 22 : AeroRadius.button,
            style: .continuous
        )
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .primary:
            RoundedRectangle(cornerRadius: AeroRadius.button, style: .continuous)
                .fill(AeroColor.accentGradient)
        case .secondary:
            RoundedRectangle(cornerRadius: AeroRadius.button, style: .continuous)
                .fill(.clear)
                .glassEffect(
                    .regular.tint(AeroColor.glassTint).interactive(),
                    in: .rect(cornerRadius: AeroRadius.button)
                )
        case .ghost:
            RoundedRectangle(cornerRadius: AeroRadius.button, style: .continuous)
                .fill(Color.white.opacity(0.06))
        case .destructive:
            RoundedRectangle(cornerRadius: AeroRadius.button, style: .continuous)
                .fill(AeroColor.error.opacity(0.16))
        case .icon:
            Circle()
                .fill(.clear)
                .glassEffect(
                    .regular.tint(AeroColor.glassTint).interactive(),
                    in: .circle
                )
        }
    }

    private var foregroundStyle: Color {
        switch kind {
        case .primary:
            .white
        case .secondary, .ghost, .icon:
            AeroColor.textPrimary
        case .destructive:
            AeroColor.error
        }
    }

    private var borderColor: Color {
        switch kind {
        case .primary:
            Color.white.opacity(0.24)
        case .secondary, .icon:
            AeroColor.stroke
        case .ghost:
            Color.white.opacity(0.08)
        case .destructive:
            AeroColor.error.opacity(0.36)
        }
    }

    private var glowColor: Color {
        switch kind {
        case .destructive:
            AeroColor.error
        default:
            AeroColor.accentGlow
        }
    }
}

/// Обёртка над Button с токенами AeroCloud.
public struct AeroButton<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let kind: AeroButtonKind
    private let fullWidth: Bool
    private let action: () -> Void
    private let label: () -> Label

    public init(
        kind: AeroButtonKind = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.kind = kind
        self.fullWidth = fullWidth
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action, label: label)
            .buttonStyle(
                AeroButtonStyle(
                    kind: kind,
                    fullWidth: fullWidth,
                    isEnabled: isEnabled,
                    reduceMotion: reduceMotion
                )
            )
    }
}

public extension AeroButton where Label == Text {
    init(
        _ title: LocalizedStringKey,
        kind: AeroButtonKind = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(kind: kind, fullWidth: fullWidth, action: action) {
            Text(title)
        }
    }
}

public extension AeroButton where Label == Image {
    init(
        systemImage: String,
        kind: AeroButtonKind = .icon,
        action: @escaping () -> Void
    ) {
        self.init(kind: kind, action: action) {
            Image(systemName: systemImage)
        }
    }
}
