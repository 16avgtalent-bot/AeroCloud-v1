import AeroCloudUI
import SwiftUI

/// Кастомный glass-таб-бар. Выбранный пункт переезжает через
/// `matchedGeometryEffect`, а весь бар живёт в `GlassEffectContainer`.
struct AeroTabBar: View {
    @Binding var selection: AeroTab
    @Namespace private var selectionNamespace

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(AeroTab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(6)
            .glassEffect(
                .regular.tint(AeroColor.glassTint).interactive(),
                in: .rect(cornerRadius: 30)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(AeroColor.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .aeroCardShadow()
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func tabButton(_ tab: AeroTab) -> some View {
        Button {
            withAnimation(AeroMotion.tab) {
                selection = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selection == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .symbolEffect(.bounce, value: selection == tab)
                Text(tab.titleKey)
                    .aeroFont(.caption2)
                    .fontWeight(selection == tab ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(
                selection == tab ? AeroColor.textPrimary : AeroColor.textTertiary
            )
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                if selection == tab {
                    Capsule()
                        .fill(AeroColor.accentStart.opacity(0.14))
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    AeroColor.accentStart.opacity(0.28),
                                    lineWidth: 0.5
                                )
                        }
                        .matchedGeometryEffect(
                            id: "tab.selection",
                            in: selectionNamespace
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.titleKey))
        .accessibilityAddTraits(
            selection == tab ? .isSelected : AccessibilityTraits()
        )
    }
}
