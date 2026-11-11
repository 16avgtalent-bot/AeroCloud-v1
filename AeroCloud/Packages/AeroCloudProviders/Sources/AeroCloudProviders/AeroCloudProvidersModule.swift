import Foundation

/// Точка входа провайдеров.
///
/// Phase 5: Apple Music (MusicKit), Spotify (PKCE + preview/Connect),
/// SoundCloud (OAuth), Deezer, Last.fm и YouTube Music за флагом.
/// Все провайдеры приводятся к `MusicProvider` из AeroCloudCore.
public enum AeroCloudProvidersModule {
    public static let version = "0.1.0"
}
