import SwiftUI

/// Карточка Liquid Glass с мягкой тенью и световым кантом.
public struct GlassCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let tint: Color
    private let interactive: Bool
    private let padding: CGFloat
    private let content: Content

    public init(
        cornerRadius: CGFloat = AeroRadius.card,
        tint: Color = AeroColor.glassTint,
        interactive: Bool = false,
        padding: CGFloat = AeroSpacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.interactive = interactive
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .glassEffect(
                .regular.tint(tint).interactive(interactive),
                in: .rect(cornerRadius: cornerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                AeroColor.strokeHighlight,
                                AeroColor.stroke,
                                AeroColor.stroke
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .aeroCardShadow()
    }
}

/// Glass-обёртка без внутреннего padding: для таб-бара, тостов и панелей.
public struct GlassSurfaceModifier: ViewModifier {
    private let cornerRadius: CGFloat
    private let tint: Color
    private let interactive: Bool

    public init(
        cornerRadius: CGFloat = AeroRadius.card,
        tint: Color = AeroColor.glassTint,
        interactive: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.interactive = interactive
    }

    public func body(content: Content) -> some View {
        content
            .glassEffect(
                .regular.tint(tint).interactive(interactive),
                in: .rect(cornerRadius: cornerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AeroColor.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}

public extension View {
    func glassSurface(
        cornerRadius: CGFloat = AeroRadius.card,
        tint: Color = AeroColor.glassTint,
        interactive: Bool = false
    ) -> some View {
        modifier(
            GlassSurfaceModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                interactive: interactive
            )
        )
    }
}
