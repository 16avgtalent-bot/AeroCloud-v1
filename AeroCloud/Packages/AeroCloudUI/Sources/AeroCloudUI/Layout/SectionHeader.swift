import SwiftUI

public struct SectionHeader: View {
    private let title: LocalizedStringKey
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    public init(
        _ title: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .aeroFont(.title3)
                .foregroundStyle(AeroColor.textPrimary)
            Spacer(minLength: AeroSpacing.sm)
            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 2) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .aeroFont(.footnote)
                    .foregroundStyle(AeroColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
