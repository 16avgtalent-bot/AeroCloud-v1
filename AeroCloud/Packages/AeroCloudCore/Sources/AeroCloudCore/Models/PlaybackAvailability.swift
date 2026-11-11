import Foundation

/// Как именно трек может быть воспроизведён.
///
/// Единый `Track` не гарантирует, что аудио доступно: Apple Music требует
/// MusicKit-подписку, Spotify отдаёт только preview/Connect, SoundCloud —
/// только разрешённые API треки.
public enum PlaybackAvailability: Codable, Hashable, Sendable {
    /// Прямой URL аудиопотока (demo, локальный файл, разрешённый API).
    case remote(URL)
    /// Воспроизведение через MusicKit по catalog id.
    case appleMusic(id: String)
    /// Короткий preview (Spotify, Deezer, Apple Music без подписки).
    case preview(URL, seconds: Int)
    /// Воспроизведение невозможно; причина показывается в UI.
    case unavailable(reason: String)
}
