import AeroCloudUI
import SwiftUI

/// Заглушка таба до Phase 4. Сохраняет визуальный ритм shell.
struct PlaceholderScreen: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let symbol: String

    var body: some View {
        VStack {
            Spacer()
            GlassCard(padding: 28) {
                VStack(spacing: AeroSpacing.md) {
                    Image(systemName: symbol)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(AeroColor.accentStart)
                        .frame(width: 72, height: 72)
                        .background {
                            Circle()
                                .fill(AeroColor.accentStart.opacity(0.10))
                        }
                    Text(title)
                        .aeroFont(.title2)
                        .foregroundStyle(AeroColor.textPrimary)
                    Text(subtitle)
                        .aeroFont(.subheadline)
                        .foregroundStyle(AeroColor.textSecondary)
                        .multilineTextAlignment(.center)
                    Text(verbatim: "Phase 4")
                        .aeroFont(.caption2)
                        .foregroundStyle(AeroColor.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background {
                            Capsule()
                                .fill(Color.white.opacity(0.06))
                        }
                }
            }
            .padding(.horizontal, AeroSpacing.xxl)
            Spacer()
        }
    }
}
