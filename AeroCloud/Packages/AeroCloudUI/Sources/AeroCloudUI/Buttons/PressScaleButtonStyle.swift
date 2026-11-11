import SwiftUI

/// Универсальный press-эффект для кастомных кнопок.
public struct PressScaleButtonStyle: ButtonStyle {
    public var scale: CGFloat
    public var pressedOpacity: Double

    public init(scale: CGFloat = 0.96, pressedOpacity: Double = 1) {
        self.scale = scale
        self.pressedOpacity = pressedOpacity
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(AeroMotion.press, value: configuration.isPressed)
    }
}
