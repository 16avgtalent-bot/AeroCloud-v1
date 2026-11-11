import Foundation

/// Источник трека. Порядок кейсов используется в source picker.
public enum MusicSource: String, Codable, CaseIterable, Hashable, Sendable {
    case appleMusic
    case spotify
    case soundCloud
    case youtubeMusic
    case deezer
    case lastFM
    case local
    case demo

    /// Отображаемое имя бренда. Локализация служебных источников — в UI-слое.
    public var displayName: String {
        switch self {
        case .appleMusic: "Apple Music"
        case .spotify: "Spotify"
        case .soundCloud: "SoundCloud"
        case .youtubeMusic: "YouTube Music"
        case .deezer: "Deezer"
        case .lastFM: "Last.fm"
        case .local: "Local"
        case .demo: "Demo"
        }
    }

    /// YouTube Music выключен по умолчанию: API и правовой режим нестабильны.
    public var isEnabledByDefault: Bool {
        self != .youtubeMusic
    }

    /// Last.fm — источник метаданных и скробблинга, а не аудиопотока.
    public var providesAudio: Bool {
        switch self {
        case .lastFM:
            false
        default:
            true
        }
    }
}
