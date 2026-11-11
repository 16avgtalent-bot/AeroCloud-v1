import AeroCloudCore
import AeroCloudUI
import SwiftUI

/// Статичный Home на demo-данных. Нужен, чтобы проверить композицию,
/// glass-слои, типографику и ритм до подключения реальных данных.
struct HomePreviewView: View {
    @State private var selectedMood = "evening"

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AeroSpacing.xl) {
                header
                WaveHeroCard()
                continueSection
                moodsSection
                Spacer(minLength: AeroSpacing.xl)
            }
            .padding(.horizontal, AeroSpacing.screen)
            .padding(.top, AeroSpacing.xs)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("home.greeting.evening")
                    .aeroFont(.title)
                    .foregroundStyle(AeroColor.textPrimary)
                Text(
                    verbatim: Date.now.formatted(
                        .dateTime.weekday(.wide).day().month(.wide)
                    )
                )
                .aeroFont(.footnote)
                .foregroundStyle(AeroColor.textSecondary)
            }
            Spacer(minLength: AeroSpacing.sm)
            Button {} label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(AeroColor.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("profile.open"))
        }
    }

    private var continueSection: some View {
        VStack(alignment: .leading, spacing: AeroSpacing.xs) {
            SectionHeader("home.continue", actionTitle: "common.seeAll") {}
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

    private var moodsSection: some View {
        VStack(alignment: .leading, spacing: AeroSpacing.sm) {
            SectionHeader("home.moods")
            ScrollView(.horizontal, showsIndicators: false) {
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach(MoodChip.all) { mood in
                            moodButton(mood)
                        }
                    }
                }
            }
        }
    }

    private func moodButton(_ mood: MoodChip) -> some View {
        Button {
            withAnimation(AeroMotion.tab) {
                selectedMood = mood.id
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: mood.symbol)
                    .font(.system(size: 12, weight: .semibold))
                Text(mood.title)
                    .aeroFont(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(
                selectedMood == mood.id
                    ? AeroColor.textPrimary
                    : AeroColor.textSecondary
            )
            .padding(.horizontal, 14)
            .frame(height: 38)
            .glassEffect(
                .regular
                    .tint(
                        mood.tint.opacity(selectedMood == mood.id ? 0.26 : 0.08)
                    )
                    .interactive(),
                in: .capsule
            )
        }
        .buttonStyle(.plain)
    }
}

private struct WaveHeroCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AeroRadius.card, style: .continuous)
                .fill(AeroColor.heroGradient)

            WaveformView(levels: nil, isActive: true, barCount: 40)
                .frame(height: 92)
                .opacity(0.34)
                .padding(.horizontal, AeroSpacing.lg)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, AeroSpacing.lg)

            VStack(alignment: .leading, spacing: AeroSpacing.xs) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text(verbatim: "AE WAVE")
                        .aeroFont(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                }
                .foregroundStyle(AeroColor.accentStart)

                Text("home.wave.title")
                    .aeroFont(.title)
                    .foregroundStyle(AeroColor.textPrimary)

                Text("home.wave.subtitle")
                    .aeroFont(.subheadline)
                    .foregroundStyle(AeroColor.textSecondary)

                HStack(spacing: 10) {
                    AeroButton("home.wave.play", kind: .primary) {}
                    AeroButton("home.wave.tune", kind: .ghost) {}
                }
                .padding(.top, 4)
            }
            .padding(AeroSpacing.lg)
        }
        .frame(height: 244)
        .glassEffect(
            .regular.tint(AeroColor.accentStart.opacity(0.10)).interactive(),
            in: .rect(cornerRadius: AeroRadius.card)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AeroRadius.card, style: .continuous)
                .strokeBorder(AeroColor.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .aeroCardShadow()
    }
}

private struct MoodChip: Identifiable, @unchecked Sendable {
    let id: String
    let title: LocalizedStringKey
    let symbol: String
    let tint: Color

    static let all: [MoodChip] = [
        MoodChip(id: "evening", title: "mood.evening", symbol: "moon.stars.fill", tint: AeroColor.accentStart),
        MoodChip(id: "focus", title: "mood.focus", symbol: "scope", tint: AeroColor.success),
        MoodChip(id: "workout", title: "mood.workout", symbol: "bolt.fill", tint: AeroColor.warning),
        MoodChip(id: "rain", title: "mood.rain", symbol: "cloud.rain.fill", tint: AeroColor.accentEnd),
        MoodChip(id: "night", title: "mood.night", symbol: "moon.fill", tint: AeroColor.like),
        MoodChip(id: "sunrise", title: "mood.sunrise", symbol: "sunrise.fill", tint: AeroColor.warning)
    ]
}
