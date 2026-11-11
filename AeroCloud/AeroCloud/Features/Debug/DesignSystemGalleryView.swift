#if DEBUG
    import AeroCloudCore
    import AeroCloudUI
    import SwiftUI

    /// Галерея дизайн-системы. Открывается launch-аргументом `-designGallery`
    /// или через Xcode Preview.
    struct DesignSystemGalleryView: View {
        @State private var vibe = 0.58
        @State private var mood = 0.42
        @State private var selectedTab: AeroTab = .home
        @State private var toastVisible = true

        var body: some View {
            ZStack {
                AuroraBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: AeroSpacing.xxl) {
                        header
                        colorSection
                        typographySection
                        buttonsSection
                        glassSection
                        tracksSection
                        sourcesSection
                        waveformSection
                        vibeSection
                        loadingSection
                        feedbackSection
                        miniPlayerSection
                        tabBarSection
                        footer
                    }
                    .padding(.horizontal, AeroSpacing.screen)
                    .padding(.top, AeroSpacing.md)
                    .padding(.bottom, AeroSpacing.xxxl)
                }
                .scrollIndicators(.hidden)
            }
            .preferredColorScheme(.dark)
        }

        private var header: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: "AEROCLOUD")
                    .aeroFont(.caption2)
                    .fontWeight(.bold)
                    .tracking(3)
                    .foregroundStyle(AeroColor.accentStart)
                Text("gallery.title")
                    .aeroFont(.largeTitle)
                    .foregroundStyle(AeroColor.textPrimary)
                Text("gallery.subtitle")
                    .aeroFont(.subheadline)
                    .foregroundStyle(AeroColor.textSecondary)
            }
        }

        private var colorSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.colors")
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 84), spacing: 10)],
                    spacing: 10
                ) {
                    ColorSwatch(name: "Background", hex: "#0A1628", color: AeroColor.background)
                    ColorSwatch(name: "Accent start", hex: "#00D4FF", color: AeroColor.accentStart)
                    ColorSwatch(name: "Accent end", hex: "#0066FF", color: AeroColor.accentEnd)
                    ColorSwatch(name: "Text", hex: "#F0F4FF", color: AeroColor.textPrimary)
                    ColorSwatch(name: "Error", hex: "#FF5A6E", color: AeroColor.error)
                    ColorSwatch(name: "Like", hex: "#FF4D8D", color: AeroColor.like)
                }
            }
        }

        private var typographySection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.typography")
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "Display 40").aeroFont(.display)
                    Text(verbatim: "Title 28").aeroFont(.title)
                    Text(verbatim: "Headline 17").aeroFont(.headline)
                    Text(verbatim: "Body 16").aeroFont(.body)
                    Text(verbatim: "Caption 11").aeroFont(.caption)
                }
                .foregroundStyle(AeroColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AeroSpacing.md)
                .glassSurface(cornerRadius: 20)
            }
        }

        private var buttonsSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.buttons")
                AeroButton("gallery.button.primary", kind: .primary, fullWidth: true) {}
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    AeroButton("gallery.button.secondary", kind: .secondary) {}
                    AeroButton("gallery.button.ghost", kind: .ghost) {}
                }
                AeroButton("gallery.button.delete", kind: .destructive, fullWidth: true) {}
                HStack(spacing: 10) {
                    AeroButton(systemImage: "play.fill") {}
                    AeroButton(systemImage: "heart.fill") {}
                    AeroButton(systemImage: "ellipsis") {}
                }
            }
        }

        private var glassSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.glass")
                GlassCard {
                    VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                        Text("gallery.glass.title")
                            .aeroFont(.headline)
                            .foregroundStyle(AeroColor.textPrimary)
                        Text("gallery.glass.body")
                            .aeroFont(.subheadline)
                            .foregroundStyle(AeroColor.textSecondary)
                        HStack(spacing: 8) {
                            SourceBadge(source: .demo)
                            SourceBadge(source: .appleMusic)
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundStyle(AeroColor.accentStart)
                        }
                    }
                }
            }
        }

        private var tracksSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.tracks")
                VStack(spacing: 4) {
                    ForEach(DemoTracks.all) { track in
                        TrackRow(
                            track: track,
                            isPlaying: track.id == DemoTracks.midnightDrive.id,
                            onTap: {},
                            onMore: {}
                        )
                    }
                }
            }
        }

        private var sourcesSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.sources")
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 76), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(MusicSource.allCases, id: \.self) { source in
                        SourceBadge(source: source)
                    }
                }
            }
        }

        private var waveformSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.waveform")
                GlassCard {
                    VStack(spacing: AeroSpacing.md) {
                        WaveformView(levels: nil, isActive: true, barCount: 64)
                            .frame(height: 64)
                        WaveformView(
                            levels: [
                                0.18, 0.42, 0.76, 0.34, 0.92, 0.48, 0.66, 0.28,
                                0.54, 0.84, 0.38, 0.72, 0.24, 0.60, 0.46, 0.30
                            ],
                            isActive: false,
                            barCount: 32
                        )
                        .frame(height: 38)
                        .opacity(0.55)
                    }
                }
            }
        }

        private var vibeSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.vibe")
                GlassCard {
                    VStack(spacing: AeroSpacing.md) {
                        VibeSlider(
                            "gallery.vibe.energy",
                            value: $vibe,
                            leading: "gallery.vibe.low",
                            trailing: "gallery.vibe.high"
                        )
                        VibeSlider(
                            "gallery.vibe.mood",
                            value: $mood,
                            leading: "gallery.vibe.melancholy",
                            trailing: "gallery.vibe.joyful",
                            tint: AeroColor.like
                        )
                    }
                }
            }
        }

        private var loadingSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.loading")
                HStack(spacing: AeroSpacing.sm) {
                    Skeleton(cornerRadius: 12)
                        .frame(width: 52, height: 52)
                    VStack(alignment: .leading, spacing: 8) {
                        Skeleton(cornerRadius: 4)
                            .frame(width: 160, height: 12)
                        Skeleton(cornerRadius: 4)
                            .frame(width: 110, height: 10)
                    }
                    Spacer(minLength: 0)
                }
                .padding(AeroSpacing.sm)
                .glassSurface(cornerRadius: 18)
            }
        }

        private var feedbackSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.feedback")
                if toastVisible {
                    ErrorToast(
                        message: "Не удалось загрузить рекомендации. Проверьте соединение.",
                        retryTitle: "common.retry",
                        onRetry: {},
                        onDismiss: {
                            withAnimation(AeroMotion.toast) {
                                toastVisible = false
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    AeroButton("gallery.feedback.show", kind: .secondary) {
                        withAnimation(AeroMotion.toast) {
                            toastVisible = true
                        }
                    }
                }
            }
        }

        private var miniPlayerSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.miniPlayer")
                MiniPlayerView(
                    track: DemoTracks.midnightDrive,
                    isPlaying: true,
                    progress: 0.42,
                    onTap: {},
                    onPlayPause: {},
                    onNext: {}
                )
            }
        }

        private var tabBarSection: some View {
            VStack(alignment: .leading, spacing: AeroSpacing.sm) {
                sectionTitle("gallery.tabBar")
                AeroTabBar(selection: $selectedTab)
            }
        }

        private var footer: some View {
            Text("gallery.footer")
                .aeroFont(.caption2)
                .foregroundStyle(AeroColor.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }

        private func sectionTitle(_ title: LocalizedStringKey) -> some View {
            Text(title)
                .aeroFont(.title3)
                .foregroundStyle(AeroColor.textPrimary)
        }
    }

    private struct ColorSwatch: View {
        let name: String
        let hex: String
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
                    .frame(height: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AeroColor.stroke, lineWidth: 1)
                    }
                Text(verbatim: name)
                    .aeroFont(.caption2)
                    .foregroundStyle(AeroColor.textPrimary)
                    .lineLimit(1)
                Text(verbatim: hex)
                    .aeroFont(.caption2)
                    .monospaced()
                    .foregroundStyle(AeroColor.textTertiary)
            }
            .padding(8)
            .glassSurface(cornerRadius: 16)
        }
    }

    #Preview {
        DesignSystemGalleryView()
    }
#endif
