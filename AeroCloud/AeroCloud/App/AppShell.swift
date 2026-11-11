import AeroCloudCore
import AeroCloudUI
import SwiftUI

/// Корневой shell: aurora-фон, контент таба, мини-плеер, таб-бар
/// и full-screen плеер как root-overlay.
struct AppShell: View {
    @State private var selectedTab: AeroTab = .home
    @State private var isPlayerPresented = false
    @State private var isPlaying = true
    @State private var trackIndex = 0
    @Namespace private var playerNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentTrack: Track {
        DemoTracks.all[trackIndex]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AuroraBackground()

            content
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: 148)
                }

            bottomChrome

            if isPlayerPresented {
                PlayerPreviewOverlay(
                    track: currentTrack,
                    isPlaying: $isPlaying,
                    namespace: playerNamespace,
                    matchedGeometryID: "player.artwork",
                    onDismiss: dismissPlayer,
                    onPrevious: previousTrack,
                    onNext: nextTrack
                )
                .zIndex(20)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
        .tint(AeroColor.accentStart)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home:
            HomePreviewView()
        case .search:
            PlaceholderScreen(
                title: "placeholder.search.title",
                subtitle: "placeholder.search.subtitle",
                symbol: "magnifyingglass"
            )
        case .wave:
            WavePreviewView()
        case .library:
            PlaceholderScreen(
                title: "placeholder.library.title",
                subtitle: "placeholder.library.subtitle",
                symbol: "books.vertical"
            )
        case .profile:
            PlaceholderScreen(
                title: "placeholder.profile.title",
                subtitle: "placeholder.profile.subtitle",
                symbol: "person.crop.circle"
            )
        }
    }

    private var bottomChrome: some View {
        VStack(spacing: 10) {
            if !isPlayerPresented {
                MiniPlayerView(
                    track: currentTrack,
                    isPlaying: isPlaying,
                    progress: 0.42,
                    matchedGeometry: MatchedGeometryContext(
                        id: "player.artwork",
                        namespace: playerNamespace
                    ),
                    onTap: presentPlayer,
                    onPlayPause: { isPlaying.toggle() },
                    onNext: nextTrack
                )
                .padding(.horizontal, AeroSpacing.md)
            }

            AeroTabBar(selection: $selectedTab)
                .padding(.horizontal, AeroSpacing.md)
        }
        .padding(.bottom, 8)
        .opacity(isPlayerPresented ? 0 : 1)
        .allowsHitTesting(!isPlayerPresented)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : AeroMotion.player, value: isPlayerPresented)
    }

    private func presentPlayer() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : AeroMotion.player) {
            isPlayerPresented = true
        }
    }

    private func dismissPlayer() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : AeroMotion.playerDismiss) {
            isPlayerPresented = false
        }
    }

    private func nextTrack() {
        withAnimation(AeroMotion.control) {
            trackIndex = (trackIndex + 1) % DemoTracks.all.count
            isPlaying = true
        }
    }

    private func previousTrack() {
        withAnimation(AeroMotion.control) {
            trackIndex = (trackIndex - 1 + DemoTracks.all.count) % DemoTracks.all.count
            isPlaying = true
        }
    }
}
