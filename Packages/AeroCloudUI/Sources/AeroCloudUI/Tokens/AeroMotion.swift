import SwiftUI

/// Единые параметры движения. Значения подобраны так, чтобы
/// переходы ощущались упругими, но не «игрушечными».
public enum AeroMotion {
    public static var tab: Animation {
        .spring(response: 0.32, dampingFraction: 0.78)
    }

    public static var player: Animation {
        .spring(response: 0.48, dampingFraction: 0.82)
    }

    public static var playerDismiss: Animation {
        .spring(response: 0.42, dampingFraction: 0.88)
    }

    public static var control: Animation {
        .spring(response: 0.28, dampingFraction: 0.65)
    }

    public static var like: Animation {
        .spring(response: 0.30, dampingFraction: 0.55)
    }

    public static var press: Animation {
        .easeOut(duration: 0.18)
    }

    public static var glowOut: Animation {
        .easeOut(duration: 0.45)
    }

    public static var slider: Animation {
        .interactiveSpring(response: 0.22, dampingFraction: 0.90)
    }

    public static var shimmer: Animation {
        .linear(duration: 1.4)
    }

    public static var coverPulse: Animation {
        .easeInOut(duration: 4.2)
    }

    public static var toast: Animation {
        .spring(response: 0.38, dampingFraction: 0.86)
    }
}
