import AeroCloudCore
import SwiftUI

/// Обложка с gradient-placeholder и инициалами.
///
/// Phase 1 использует `AsyncImage`; в Phase 3 внутренность заменяется
/// на Nuke с дисковым кэшем без изменения call sites.
public struct ArtworkView: View {
    private let url: URL?
    private let cornerRadius: CGFloat
    private let title: String
    private let artist: String

    public init(
        url: URL?,
        cornerRadius: CGFloat = 12,
        title: String = "",
        artist: String = ""
    ) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.title = title
        self.artist = artist
    }

    public var body: some View {
        ZStack {
            placeholder
            if let url {
                AsyncImage(
                    url: url,
                    transaction: Transaction(animation: .easeOut(duration: 0.25))
                ) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    case .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        }
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x123A5A), Color(hex: 0x071426)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [AeroColor.accentStart.opacity(0.16), .clear],
                center: .topLeading,
                startRadius: 2,
                endRadius: 90
            )
            Text(verbatim: initials)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AeroColor.textSecondary)
        }
    }

    private var initials: String {
        let words = title.split(separator: " ")
        let letters = words.prefix(2).compactMap(\.first)
        if letters.isEmpty {
            return artist.first.map(String.init)?.uppercased() ?? "A"
        }
        return String(letters).uppercased()
    }
}
