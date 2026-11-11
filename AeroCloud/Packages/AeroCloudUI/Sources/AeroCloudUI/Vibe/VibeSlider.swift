import SwiftUI

/// Кастомный слайдер вайба: 0...1, glass-thumb, haptics по шагам.
public struct VibeSlider: View {
    private let title: LocalizedStringKey
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let leading: LocalizedStringKey?
    private let trailing: LocalizedStringKey?
    private let tint: Color

    public init(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0 ... 1,
        leading: LocalizedStringKey? = nil,
        trailing: LocalizedStringKey? = nil,
        tint: Color = AeroColor.accentStart
    ) {
        self.title = title
        _value = value
        self.range = range
        self.leading = leading
        self.trailing = trailing
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AeroSpacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .aeroFont(.subheadline)
                    .foregroundStyle(AeroColor.textPrimary)
                Spacer(minLength: AeroSpacing.sm)
                Text(verbatim: "\(percent)%")
                    .aeroFont(.caption)
                    .monospacedDigit()
                    .foregroundStyle(AeroColor.textTertiary)
            }

            GeometryReader { geometry in
                sliderTrack(width: geometry.size.width)
            }
            .frame(height: 32)

            if leading != nil || trailing != nil {
                HStack {
                    if let leading {
                        Text(leading)
                    }
                    Spacer(minLength: AeroSpacing.sm)
                    if let trailing {
                        Text(trailing)
                    }
                }
                .aeroFont(.caption2)
                .foregroundStyle(AeroColor.textTertiary)
            }
        }
        .sensoryFeedback(.selection, trigger: step)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(verbatim: "\(percent)%"))
        .accessibilityAdjustableAction { direction in
            adjust(direction)
        }
    }

    private var normalizedValue: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return min(max((value - range.lowerBound) / span, 0), 1)
    }

    private var percent: Int {
        Int((normalizedValue * 100).rounded())
    }

    private var step: Int {
        Int((normalizedValue * 10).rounded())
    }

    private func sliderTrack(width: CGFloat) -> some View {
        let thumbSize: CGFloat = 24
        let thumbX = min(
            max(width * normalizedValue - thumbSize / 2, 0),
            max(width - thumbSize, 0)
        )

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.10))
                .frame(height: 6)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [tint, AeroColor.accentEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(0, width * normalizedValue), height: 6)

            Circle()
                .fill(AeroColor.textPrimary)
                .frame(width: thumbSize, height: thumbSize)
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                }
                .shadow(color: tint.opacity(0.55), radius: 10, x: 0, y: 0)
                .offset(x: thumbX)
        }
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    update(at: gesture.location.x, width: width)
                }
        )
    }

    private func update(at x: CGFloat, width: CGFloat) {
        guard width > 0 else { return }
        let fraction = min(max(x / width, 0), 1)
        let span = range.upperBound - range.lowerBound
        value = range.lowerBound + Double(fraction) * span
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        let span = range.upperBound - range.lowerBound
        let increment = span * 0.05
        switch direction {
        case .increment:
            value = min(value + increment, range.upperBound)
        case .decrement:
            value = max(value - increment, range.lowerBound)
        @unknown default:
            break
        }
    }
}
