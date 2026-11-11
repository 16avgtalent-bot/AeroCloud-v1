import Foundation

/// Единая модель трека для всех провайдеров.
///
/// `id` строится из источника и `sourceID`, поэтому один и тот же трек
/// из Apple Music и Spotify — две разные записи до дедупликации по ISRC.
public struct Track: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String?
    public let artworkURL: URL?
    public let duration: TimeInterval
    public let source: MusicSource
    public let sourceID: String
    public let isrc: String?
    public let releaseYear: Int?
    public let isExplicit: Bool
    public let language: TrackLanguage
    public var playback: PlaybackAvailability
    public var features: TrackFeatures?

    public init(
        title: String,
        artist: String,
        album: String? = nil,
        artworkURL: URL? = nil,
        duration: TimeInterval,
        source: MusicSource,
        sourceID: String,
        isrc: String? = nil,
        releaseYear: Int? = nil,
        isExplicit: Bool = false,
        language: TrackLanguage = .unknown,
        playback: PlaybackAvailability = .unavailable(reason: "Недоступно"),
        features: TrackFeatures? = nil
    ) {
        id = "\(source.rawValue):\(sourceID)"
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkURL = artworkURL
        self.duration = duration
        self.source = source
        self.sourceID = sourceID
        self.isrc = isrc
        self.releaseYear = releaseYear
        self.isExplicit = isExplicit
        self.language = language
        self.playback = playback
        self.features = features
    }

    public var durationText: String {
        guard duration.isFinite, duration > 0 else { return "--:--" }
        let total = Int(duration.rounded())
        return String(format: "%ld:%02ld", total / 60, total % 60)
    }

    public var isPlayable: Bool {
        switch playback {
        case .remote, .appleMusic, .preview:
            true
        case .unavailable:
            false
        }
    }

    public var subtitle: String {
        if let album, !album.isEmpty {
            return "\(artist) — \(album)"
        }
        return artist
    }
}
