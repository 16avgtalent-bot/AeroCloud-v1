import Foundation

/// Язык вокала. Нужен AE Wave, чтобы не смешивать русский и английский
/// в одной волне без явного запроса пользователя.
public enum TrackLanguage: String, Codable, CaseIterable, Hashable, Sendable {
    case russian
    case english
    case instrumental
    case other
    case unknown
}
