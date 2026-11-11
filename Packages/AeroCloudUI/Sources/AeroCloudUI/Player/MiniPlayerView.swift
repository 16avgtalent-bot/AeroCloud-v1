import AeroCloudCore
import SwiftUI

/// Мини-плеер над таб-баром. Обложка умеет перелетать в full-screen плеер
/// через `MatchedGeometryContext`.
public struct MiniPlayerView: View {
    private let track: Track
    private let isPlaying: Bool
    private let progress: Double
    private let onTap: () -> Void
    private let onPlayPause: () -> Void
    private let onNext: () -> Void
    private let matchedGeometry: MatchedGeometryContext?

    public init(
        track: Track,
        isPlaying: Bool,
        progress: Double,
        matchedGeometry: MatchedGeometryContext? = nil,
        onTap: @escaping () -> Void,
        onPlayPause: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.track = track
        self.isPlaying = isPlaying
        self.progress = progress
        self.matchedGeometry = matchedGeometry
        self.onTap = onTap
        self.onPlayPause = onPlayPause
        self.onNext = onNext
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AeroSpacing.sm) {
                artwork
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: track.title)
                        .aeroFont(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AeroColor.textPrimary)
                        .lineLimit(1)
                    Text(verbatim: track.artist)
                        .aeroFont(.caption)
                        .foregroundStyle(AeroColor.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: AeroSpacing.xs)
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(GlowButtonStyle(size: 36))
                .accessibilityLabel(Text(playPauseTitle))

                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 13, weight: .bold))
                }
                .buttonStyle(GlowButtonStyle(size: 36))
                .accessibilityLabel(Text("player.next"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            progressBar
        }
        .glassEffect(
            .regular.tint(AeroColor.glassTint).interactive(),
            in: .rect(cornerRadius: 26)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(AeroColor.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .aeroCardShadow()
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: Text("player.open")) {
            onTap()
        }
    }

    private var playPauseTitle: LocalizedStringKey {
        isPlaying ? "player.pause" : "player.play"
    }

    @ViewBuilder
    private var artwork: some View {
        let base = ArtworkView(
            url: track.artworkURL,
            cornerRadius: 8,
            title: track.title,
            artist: track.artist
        )
        .frame(width: 44, height: 44)

        if let matchedGeometry {
            base.matchedGeometryEffect(
                id: matchedGeometry.id,
                in: matchedGeometry.namespace
            )
        } else {
            base
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.10))
                Capsule()
                    .fill(AeroColor.accentGradient)
                    .frame(width: geometry.size.width * clampedProgress)
            }
        }
        .frame(height: 2)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}
