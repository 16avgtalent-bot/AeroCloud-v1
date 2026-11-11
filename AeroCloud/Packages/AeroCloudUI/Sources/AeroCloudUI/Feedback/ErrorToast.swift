import SwiftUI

/// Glass-тост для ошибок с действием «Повторить».
public struct ErrorToast: View {
    private let message: String
    private let retryTitle: LocalizedStringKey?
    private let onRetry: (() -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        message: String,
        retryTitle: LocalizedStringKey? = nil,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: AeroSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AeroColor.warning)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .aeroFont(.subheadline)
                    .foregroundStyle(AeroColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let retryTitle, let onRetry {
                    Button(action: onRetry) {
                        Text(retryTitle)
                            .aeroFont(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AeroColor.accentStart)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AeroColor.textTertiary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("common.close"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassSurface(cornerRadius: 18)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AeroColor.warning)
                .frame(width: 3)
                .padding(.vertical, 10)
        }
        .aeroCardShadow()
        .accessibilityElement(children: .contain)
    }
}
