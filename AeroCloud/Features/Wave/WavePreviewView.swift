import AeroCloudCore
import AeroCloudUI
import SwiftUI

/// Статичный экран AE Wave: обложка, waveform, вайб-слайдеры и контролы.
/// Реальная лента и объяснения появятся в Phase 7.
struct WavePreviewView: View {
    @State private var energy = 0.62
    @State private var valence = 0.48
    @State private var freshness = 0.35
    @State private var isPlaying = true

    private let track = DemoTracks.glassHorizon

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AeroSpacing.lg) {
                header
                artwork
                reason
                waveform
                vibeCard
                controls
            }
            .padding(.horizontal, AeroSpacing.screen)
            .padding(.top, AeroSpacing.xs)
            .padding(.bottom, AeroSpacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("wave.title")
                .aeroFont(.largeTitle)
                .foregroundStyle(AeroColor.textPrimary)
            Text("wave.subtitle")
                .aeroFont(.subheadline)
                .foregroundStyle(AeroColor.textSecondary)
        }
    }

    private var artwork: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, 300)
            ArtworkView(
                url: track.artworkURL,
                cornerRadius: AeroRadius.card,
                title: track.title,
                artist: track.artist
            )
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity)
            .shadow(color: AeroColor.accentGlow.opacity(0.18), radius: 30, x: 0, y: 18)
        }
        .frame(height: 300)
    }

    private var reason: some View {
        HStack(spacing: AeroSpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AeroColor.accentStart)
            Text("wave.reason")
                .aeroFont(.caption)
                .foregroundStyle(AeroColor.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .glassSurface(cornerRadius: 16)
    }

    private var waveform: some View {
        WaveformView(levels: nil, isActive: isPlaying, barCount: 56)
            .frame(height: 58)
            .padding(.horizontal, AeroSpacing.xs)
    }

    private var vibeCard: some View {
        GlassCard(padding: 18) {
            VStack(alignment: .leading, spacing: AeroSpacing.md) {
                HStack {
                    Text("wave.vibe")
                        .aeroFont(.headline)
                        .foregroundStyle(AeroColor.textPrimary)
                    Spacer()
                    Button {
                        withAnimation(AeroMotion.control) {
                            energy = 0.5
                            valence = 0.5
                            freshness = 0.35
                        }
                    } label: {
                        Text("wave.reset")
                            .aeroFont(.caption)
                            .foregroundStyle(AeroColor.accentStart)
                    }
                    .buttonStyle(.plain)
                }

                VibeSlider(
                    "wave.energy",
                    value: $energy,
                    leading: "wave.calm",
                    trailing: "wave.intense",
                    tint: AeroColor.accentStart
                )
                VibeSlider(
                    "wave.mood",
                    value: $valence,
                    leading: "wave.melancholy",
                    trailing: "wave.joyful",
                    tint: AeroColor.like
                )
                VibeSlider(
                    "wave.freshness",
                    value: $freshness,
                    leading: "wave.familiar",
                    trailing: "wave.fresh",
                    tint: AeroColor.success
                )
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 14) {
            controlButton("shuffle", label: "player.shuffle") {}
            controlButton("backward.fill", label: "player.previous") {}
            PlayPauseButton(isPlaying: isPlaying, size: 68) {
                isPlaying.toggle()
            }
            controlButton("forward.fill", label: "player.next") {}
            controlButton("repeat", label: "player.repeat") {}
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AeroSpacing.xxs)
    }

    private func controlButton(
        _ symbol: String,
        label: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
        }
        .buttonStyle(GlowButtonStyle(size: 42))
        .accessibilityLabel(Text(label))
    }
}
