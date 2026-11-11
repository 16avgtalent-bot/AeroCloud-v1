import SwiftUI

/// Многослойный aurora-фон: mesh-градиент, шум и мягкое затемнение.
/// Анимация отключается при Reduce Motion.
public struct AuroraBackground: View {
    private let animated: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Float = 0

    public init(animated: Bool = true) {
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            AeroColor.background
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: colors
            )
            .opacity(0.92)
            .blur(radius: 6)
            NoiseOverlay()
            LinearGradient(
                colors: [.clear, AeroColor.background.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .onAppear {
            guard animated, !reduceMotion else { return }
            phase = 0
            withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private var points: [SIMD2<Float>] {
        let wave = sin(Double(phase) * .pi)
        let counterWave = cos(Double(phase) * .pi)
        return [
            SIMD2(0, 0),
            SIMD2(Float(0.5 + 0.04 * wave), 0),
            SIMD2(1, 0),
            SIMD2(0, 0.5),
            SIMD2(Float(0.5 + 0.05 * counterWave), Float(0.5 + 0.03 * wave)),
            SIMD2(1, 0.5),
            SIMD2(0, 1),
            SIMD2(Float(0.5 - 0.04 * wave), 1),
            SIMD2(1, 1)
        ]
    }

    private var colors: [Color] {
        [
            AeroColor.background,
            Color(hex: 0x0B2A4A),
            AeroColor.background,
            Color(hex: 0x0A1F3D),
            AeroColor.accentEnd.opacity(0.32),
            Color(hex: 0x0B2A4A),
            AeroColor.background,
            Color(hex: 0x06304D),
            AeroColor.background
        ]
    }
}

/// Детерминированный шум без ассетов. Рисуется один раз на размер,
/// не каждый кадр, поэтому не влияет на 120 fps.
private struct NoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            var random = SplitMix64(seed: 0xA3C10D)
            for _ in 0 ..< 2200 {
                let x = random.nextUnit() * size.width
                let y = random.nextUnit() * size.height
                let alpha = 0.02 + random.nextUnit() * 0.10
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.white.opacity(alpha)))
            }
        }
        .blendMode(.plusLighter)
        .opacity(0.035)
        .allowsHitTesting(false)
    }
}

private struct SplitMix64 {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }

    mutating func nextUnit() -> CGFloat {
        CGFloat(next() >> 11) / CGFloat(1 << 53)
    }
}
