import SwiftUI

/// Волна из 64 баров. В Phase 1 — idle-анимация и массив уровней;
/// в Phase 3 сюда будет приходить реальный tap из AVAudioEngine.
public struct WaveformView: View {
    private let levels: [CGFloat]?
    private let isActive: Bool
    private let barCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        levels: [CGFloat]? = nil,
        isActive: Bool = true,
        barCount: Int = 64
    ) {
        self.levels = levels
        self.isActive = isActive
        self.barCount = barCount
    }

    public var body: some View {
        let levels = levels
        let isActive = isActive
        let reduceMotion = reduceMotion
        let barCount = barCount

        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0,
                paused: !isActive || reduceMotion
            )
        ) { timeline in
            Canvas { context, size in
                WaveformRenderer.draw(
                    context: &context,
                    size: size,
                    date: timeline.date,
                    levels: levels,
                    isActive: isActive,
                    reduceMotion: reduceMotion,
                    barCount: barCount
                )
            }
        }
        .accessibilityLabel(Text(accessibilityTitle))
    }

    private var accessibilityTitle: LocalizedStringKey {
        isActive ? "waveform.active" : "waveform.idle"
    }
}

private enum WaveformRenderer {
    static func draw(
        context: inout GraphicsContext,
        size: CGSize,
        date: Date,
        levels: [CGFloat]?,
        isActive: Bool,
        reduceMotion: Bool,
        barCount: Int
    ) {
        guard size.width > 0, size.height > 0 else { return }
        let count = max(barCount, 1)
        let step = size.width / CGFloat(count)
        let barWidth = max(1.5, step * 0.52)
        let time = date.timeIntervalSinceReferenceDate

        for index in 0 ..< count {
            let level = level(
                at: index,
                count: count,
                time: time,
                levels: levels,
                isActive: isActive,
                reduceMotion: reduceMotion
            )
            let height = max(2, level * size.height)
            let x = CGFloat(index) * step + (step - barWidth) / 2
            let rect = CGRect(
                x: x,
                y: (size.height - height) / 2,
                width: barWidth,
                height: height
            )
            let path = Path(roundedRect: rect, cornerRadius: barWidth / 2)
            context.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [AeroColor.accentStart, AeroColor.accentEnd]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: 0)
                )
            )
        }
    }

    private static func level(
        at index: Int,
        count: Int,
        time: TimeInterval,
        levels: [CGFloat]?,
        isActive: Bool,
        reduceMotion: Bool
    ) -> CGFloat {
        if let levels, !levels.isEmpty {
            let normalized = CGFloat(index) / CGFloat(max(count - 1, 1))
            let sourceIndex = Int(normalized * CGFloat(levels.count - 1))
            return min(max(levels[sourceIndex], 0), 1)
        }

        guard isActive, !reduceMotion else {
            return 0.14
        }

        let base = 0.20 + 0.11 * sin(time * 1.7 + Double(index) * 0.33)
        let pulse = 0.07 * sin(time * 3.1 + Double(index) * 0.71)
        let envelope = 0.72 + 0.28 * sin(Double(index) / Double(count) * .pi)
        return CGFloat(min(max((base + pulse) * envelope, 0.08), 1))
    }
}
