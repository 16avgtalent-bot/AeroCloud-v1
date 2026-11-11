import Observation

/// Контейнер зависимостей. Phase 2 добавит провайдеры, репозитории,
/// SwiftData-контейнер и плеер. Пока класс существует, чтобы app entry
/// и shell не меняли форму при подключении зависимостей.
@MainActor
@Observable
final class AppDependencies {
    init() {}
}
