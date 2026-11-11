import AeroCloudCore
import SwiftUI

/// Строка трека: обложка, название, артист, источник, длительность.
public struct TrackRow: View {
    private let track: Track
    private let isPlaying: Bool
    private let showSourceBadge: Bool
    private let onTap: (() -> Void)?
    private let onMore: (() -> Void)?

    public init(
        track: Track,
        isPlaying: Bool = false,
        showSourceBadge: Bool = true,
        onTap: (() -> Void)? = nil,
        onMore: (() -> Void)? = nil
    ) {
        self.track = track
        self.isPlaying = isPlaying
        self.showSourceBadge = showSourceBadge
        self.onTap = onTap
        self.onMore = onMore
    }

    public var body: some View {
        HStack(spacing: AeroSpacing.sm) {
            artwork
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(verbatim: track.title)
                        .aeroFont(.headline)
                        .foregroundStyle(AeroColor.textPrimary)
                        .lineLimit(1)
                    if track.isExplicit {
                        Text(verbatim: "E")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(AeroColor.textSecondary)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                            }
                    }
                }
                Text(verbatim: track.artist)
                    .aeroFont(.subheadline)
                    .foregroundStyle(AeroColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: AeroSpacing.xs)
            if showSourceBadge {
                SourceBadge(source: track.source)
            }
            Text(verbatim: track.durationText)
                .aeroFont(.caption)
                .monospacedDigit()
                .foregroundStyle(AeroColor.textTertiary)
            if let onMore {
                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AeroColor.textTertiary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(verbatim: "\(track.title), \(track.artist), \(track.durationText)"))
        .accessibilityAction(named: Text("common.more")) {
            onMore?()
        }
    }

    private var artwork: some View {
        ZStack(alignment: .bottomTrailing) {
            ArtworkView(
                url: track.artworkURL,
                cornerRadius: 10,
                title: track.title,
                artist: track.artist
            )
            .frame(width: 52, height: 52)
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AeroColor.background)
                    .frame(width: 20, height: 20)
                    .background {
                        Circle().fill(AeroColor.accentStart)
                    }
                    .symbolEffect(.variableColor.iterative, isActive: isPlaying)
                    .padding(3)
            }
        }
    }
}
