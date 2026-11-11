import SwiftUI

enum AeroTab: String, CaseIterable, Identifiable, Hashable {
    case home
    case search
    case wave
    case library
    case profile

    var id: String {
        rawValue
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .home: "tab.home"
        case .search: "tab.search"
        case .wave: "tab.wave"
        case .library: "tab.library"
        case .profile: "tab.profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .wave: "waveform"
        case .library: "books.vertical"
        case .profile: "person.crop.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: "house.fill"
        case .search: "magnifyingglass"
        case .wave: "waveform"
        case .library: "books.vertical.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}
