import Foundation

/// Навигационные маршруты внутри таба. Phase 4 подключит их к координаторам.
enum AppRoute: Hashable {
    case artist(id: String)
    case album(id: String)
    case playlist(id: String)
    case trackGroup(id: String)
    case downloads
    case settings
    case vibeEditor
}
