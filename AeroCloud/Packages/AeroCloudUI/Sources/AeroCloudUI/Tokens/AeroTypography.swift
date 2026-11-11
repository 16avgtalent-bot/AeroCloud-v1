import SwiftUI

/// Типографические токены. Размеры масштабируются Dynamic Type
/// через `@ScaledMetric` в `AeroFontModifier`.
public enum AeroFontToken: Sendable {
    case display
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2

    var size: CGFloat {
        switch self {
        case .display: 40
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .body: 16
        case .callout: 15
        case .subheadline: 14
        case .footnote: 12
        case .caption: 11
        case .caption2: 10
        }
    }

    var weight: Font.Weight {
        switch self {
        case .display, .largeTitle: .bold
        case .title, .title2, .title3, .headline: .semibold
        case .body, .callout, .subheadline, .footnote, .caption, .caption2: .regular
        }
    }

    var design: Font.Design {
        switch self {
        case .display, .largeTitle, .title, .title2, .title3, .headline:
            .rounded
        default:
            .default
        }
    }

    var relativeTo: Font.TextStyle {
        switch self {
        case .display, .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption
        case .caption2: .caption2
        }
    }
}

public struct AeroFontModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    public init(_ token: AeroFontToken) {
        _size = ScaledMetric(wrappedValue: token.size, relativeTo: token.relativeTo)
        weight = token.weight
        design = token.design
    }

    public func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

public extension View {
    func aeroFont(_ token: AeroFontToken) -> some View {
        modifier(AeroFontModifier(token))
    }
}
