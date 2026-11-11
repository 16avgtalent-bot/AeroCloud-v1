import AeroCloudCore
import AeroCloudUI
import SwiftUI

/// Full-screen плеер как root-overlay. Обложка связана с мини-плеером
/// через matched geometry; остальное — статичный Phase 1 preview.
struct PlayerPreviewOverlay: View {
    let track: Track
    @Binding var isPlaying: Bool
    let namespace: Namespace.ID
    let matchedGeometryID: String
    let onDismiss: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    @State private var dragOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let artworkSide = min(
                geometry.size.width - 48,
                geometry.size.height * 0.38,
                340
            )

            ZStack {
                AuroraBackground(animated: true)
                    .blur(radius: 24)
                    .overlay(Color.black.opacity(0.32))
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    dragHandle
                    topBar
                    artwork(side: artworkSide)
                    titleBlock
                    waveform
                    progress
                    controls
                    actions
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, AeroSpacing.xl)
                .padding(.bottom, AeroSpacing.md)
            }
        }
        .offset(y: dragOffset)
        .gesture(dragGesture)
        .transition(.opacity)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.25))
            .frame(width: 36, height: 5)
            .padding(.top, AeroSpacing.xs)
    }

    private var topBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .bold))
            }
            .buttonStyle(GlowButtonStyle(size: 40))
            .accessibilityLabel(Text("player.close"))

            Spacer()

            VStack(spacing: 1) {
                Text("player.nowPlaying")
                    .aeroFont(.caption2)
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(AeroColor.textTertiary)
                Text(verbatim: track.source.displayName)
                    .aeroFont(.caption)
                    .foregroundStyle(AeroColor.textSecondary)
            }

            Spacer()

            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .bold))
            }
            .buttonStyle(GlowButtonStyle(size: 40))
            .accessibilityLabel(Text("common.more"))
        }
    }

    private func artwork(side: CGFloat) -> some View {
        ArtworkView(
            url: track.artworkURL,
            cornerRadius: AeroRadius.card,
            title: track.title,
            artist: track.artist
        )
        .frame(width: side, height: side)
        .frame(maxWidth: .infinity)
        .matchedGeometryEffect(id: matchedGeometryID, in: namespace)
        .shadow(color: AeroColor.accentGlow.opacity(0.20), radius: 34, x: 0, y: 18)
    }

    private var titleBlock: some View {
        VStack(spacing: 4) {
            Text(verbatim: track.title)
                .aeroFont(.title2)
                .foregroundStyle(AeroColor.textPrimary)
                .lineLimit(1)
            Text(verbatim: track.artist)
                .aeroFont(.subheadline)
                .foregroundStyle(AeroColor.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var waveform: some View {
        WaveformView(levels: nil, isActive: isPlaying, barCount: 52)
            .frame(height: 48)
            .padding(.horizontal, AeroSpacing.xs)
    }

    private var progress: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(AeroColor.accentGradient)
                        .frame(width: geometry.size.width * 0.42)
                    Circle()
                        .fill(AeroColor.textPrimary)
                        .frame(width: 10, height: 10)
                        .offset(x: geometry.size.width * 0.42 - 5)
                }
            }
            .frame(height: 6)

            HStack {
                Text(verbatim: "1:24")
                Spacer()
                Text(verbatim: "-2:10")
            }
            .aeroFont(.caption2)
            .monospacedDigit()
            .foregroundStyle(AeroColor.textTertiary)
        }
    }

    private var controls: some View {
        HStack(spacing: 14) {
            controlButton("shuffle", label: "player.shuffle") {}
            controlButton("backward.fill", label: "player.previous", action: onPrevious)
            PlayPauseButton(isPlaying: isPlaying, size: 68) {
                isPlaying.toggle()
            }
            controlButton("forward.fill", label: "player.next", action: onNext)
            controlButton("repeat", label: "player.repeat") {}
        }
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        HStack(spacing: 30) {
            actionButton("heart", title: "player.like") {}
            actionButton("arrow.down.circle", title: "player.download") {}
            actionButton("square.and.arrow.up", title: "player.share") {}
            actionButton("list.bullet", title: "player.queue") {}
        }
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

    private func actionButton(
        _ symbol: String,
        title: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .aeroFont(.caption2)
            }
            .foregroundStyle(AeroColor.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    onDismiss()
                } else {
                    withAnimation(
                        reduceMotion
                            ? .easeOut(duration: 0.2)
                            : AeroMotion.playerDismiss
                    ) {
                        dragOffset = 0
                    }
                }
            }
    }
}
