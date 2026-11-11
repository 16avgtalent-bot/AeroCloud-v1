import AeroCloudCore
import SwiftUI

public extension MusicSource {
    /// SF Symbol для бейджа источника. Брендовые логотипы не используем,
    /// чтобы не тащить чужие ассеты и не нарушать гайдлайны.
    var symbolName: String {
        switch self {
        case .appleMusic: "apple.logo"
        case .spotify: "waveform"
        case .soundCloud: "cloud.fill"
        case .youtubeMusic: "play.rectangle.fill"
        case .deezer: "music.note.list"
        case .lastFM: "antenna.radiowaves.left.and.right"
        case .local: "iphone"
        case .demo: "sparkles"
        }
    }

    /// Короткая подпись для компактного бейджа.
    var shortLabel: String {
        switch self {
        case .appleMusic: "AM"
        case .spotify: "SP"
        case .soundCloud: "SC"
        case .youtubeMusic: "YT"
        case .deezer: "DZ"
        case .lastFM: "LF"
        case .local: "LOC"
        case .demo: "DEMO"
        }
    }
}
