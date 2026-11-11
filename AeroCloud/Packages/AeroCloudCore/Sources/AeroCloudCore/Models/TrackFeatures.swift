import Foundation

/// Content-based признаки трека для AE Wave.
///
/// Все значения, кроме `tempo`, нормализованы в 0...1. `tempo` — BPM.
/// Признаки могут быть неизвестны (nil) — движок использует fallback
/// на жанр, источник и поведение пользователя.
public struct TrackFeatures: Codable, Hashable, Sendable {
    public var energy: Double?
    public var valence: Double?
    public var tempo: Double?
    public var danceability: Double?
    public var acousticness: Double?
    public var instrumentalness: Double?
    public var speechiness: Double?
    public var liveness: Double?

    public init(
        energy: Double? = nil,
        valence: Double? = nil,
        tempo: Double? = nil,
        danceability: Double? = nil,
        acousticness: Double? = nil,
        instrumentalness: Double? = nil,
        speechiness: Double? = nil,
        liveness: Double? = nil
    ) {
        self.energy = energy
        self.valence = valence
        self.tempo = tempo
        self.danceability = danceability
        self.acousticness = acousticness
        self.instrumentalness = instrumentalness
        self.speechiness = speechiness
        self.liveness = liveness
    }

    /// Нейтральный профиль: используется, когда провайдер не отдал признаки.
    public static let neutral = TrackFeatures(
        energy: 0.5,
        valence: 0.5,
        tempo: 110,
        danceability: 0.5,
        acousticness: 0.3,
        instrumentalness: 0.3,
        speechiness: 0.05,
        liveness: 0.1
    )
}
