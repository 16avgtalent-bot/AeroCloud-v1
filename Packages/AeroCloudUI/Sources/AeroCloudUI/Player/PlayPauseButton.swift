import SwiftUI

/// Большая акцентная кнопка play/pause с glow.
public struct PlayPauseButton: View {
    private let isPlaying: Bool
    private let size: CGFloat
    private let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        isPlaying: Bool,
        size: CGFloat = 76,
        action: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AeroColor.accentGradient)
                Circle()
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.30, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(x: isPlaying ? 0 : 2)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: size, height: size)
            .shadow(color: AeroColor.accentGlow.opacity(0.55), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(PressScaleButtonStyle(scale: reduceMotion ? 1 : 0.94))
        .animation(AeroMotion.control, value: isPlaying)
        .accessibilityLabel(Text(playPauseTitle))
    }

    private var playPauseTitle: LocalizedStringKey {
        isPlaying ? "player.pause" : "player.play"
    }
}
