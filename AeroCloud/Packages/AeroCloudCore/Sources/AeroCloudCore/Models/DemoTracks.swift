import Foundation

/// Временный demo-каталог для Phase 0–1.
///
/// Аудиофайлы появятся в Phase 2 (CC0/CC-BY). Сейчас нужны только
/// визуальные данные для дизайн-системы и превью.
public enum DemoTracks {
    public static let midnightDrive = Track(
        title: "Midnight Drive",
        artist: "Nova Lane",
        album: "Night Geometry",
        duration: 214,
        source: .demo,
        sourceID: "midnight-drive",
        releaseYear: 2025,
        language: .instrumental,
        playback: .unavailable(reason: "Demo audio появится в Phase 2"),
        features: TrackFeatures(
            energy: 0.72,
            valence: 0.48,
            tempo: 118,
            danceability: 0.66,
            acousticness: 0.12,
            instrumentalness: 0.91,
            speechiness: 0.03,
            liveness: 0.08
        )
    )

    public static let glassHorizon = Track(
        title: "Glass Horizon",
        artist: "Aster Vale",
        album: "Soft Machines",
        duration: 187,
        source: .demo,
        sourceID: "glass-horizon",
        releaseYear: 2025,
        language: .english,
        playback: .unavailable(reason: "Demo audio появится в Phase 2"),
        features: TrackFeatures(
            energy: 0.54,
            valence: 0.62,
            tempo: 104,
            danceability: 0.58,
            acousticness: 0.24,
            instrumentalness: 0.18,
            speechiness: 0.06,
            liveness: 0.12
        )
    )

    public static let afterRain = Track(
        title: "After Rain",
        artist: "Kite & Moss",
        album: "Low Clouds",
        duration: 243,
        source: .demo,
        sourceID: "after-rain",
        releaseYear: 2024,
        language: .russian,
        playback: .unavailable(reason: "Demo audio появится в Phase 2"),
        features: TrackFeatures(
            energy: 0.38,
            valence: 0.44,
            tempo: 88,
            danceability: 0.41,
            acousticness: 0.62,
            instrumentalness: 0.05,
            speechiness: 0.08,
            liveness: 0.16
        )
    )

    public static let all: [Track] = [
        midnightDrive,
        glassHorizon,
        afterRain
    ]
}
