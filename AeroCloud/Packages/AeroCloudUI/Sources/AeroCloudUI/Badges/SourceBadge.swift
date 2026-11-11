import AeroCloudCore
import SwiftUI

/// Компактный бейдж источника. Цвет и SF Symbol — из UI-слоя,
/// чтобы Core не зависел от SwiftUI.
public struct SourceBadge: View {
    private let source: MusicSource
    private let compact: Bool

    public init(source: MusicSource, compact: Bool = false) {
        self.source = source
        self.compact = compact
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: source.symbolName)
                .font(.system(size: compact ? 8 : 9, weight: .bold))
            if !compact {
                Text(verbatim: source.shortLabel)
                    .aeroFont(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(AeroColor.sourceColor(source))
        .padding(.horizontal, compact ? 4 : 6)
        .frame(height: 18)
        .background {
            Capsule()
                .fill(AeroColor.sourceColor(source).opacity(0.12))
        }
        .overlay {
            Capsule()
                .strokeBorder(AeroColor.sourceColor(source).opacity(0.24), lineWidth: 0.5)
        }
        .accessibilityLabel(Text("common.source") + Text(verbatim: " \(source.displayName)"))
    }
}
