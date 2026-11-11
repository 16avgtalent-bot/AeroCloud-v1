import SwiftUI

/// Контекст для перелёта обложки между мини-плеером и full-screen плеером.
public struct MatchedGeometryContext {
    public let id: String
    public let namespace: Namespace.ID

    public init(id: String, namespace: Namespace.ID) {
        self.id = id
        self.namespace = namespace
    }
}
