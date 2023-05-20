// The code is applicable only for iOS environment
#if os(iOS)
import SwiftUI
#endif

// Enum HapticFeedbackStyle is defined to hold different types of haptic feedback styles.
enum HapticFeedbackStyle {
    case heavy
    case light
    case medium
    case rigid
    case soft
    
    // The code in this block is only compiled if the operating system is iOS
    #if os(iOS)
    // Mapping each case of the custom HapticFeedbackStyle enum to the corresponding UIKit haptic feedback style
    var uiFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .heavy:
            return .heavy
        case .light:
            return .light
        case .medium:
            return .medium
        case .rigid:
            return .rigid
        case .soft:
            return .soft
        }
    }
    #endif
}

// The function vibrate() takes HapticFeedbackStyle as input and generates a haptic feedback according to the selected style
// This function is a wrapper over iosVibrate() function and provides a platform agnostic API for the rest of the application
func vibrate(_ style: HapticFeedbackStyle) {
    #if os(iOS)
    iosVibrate(style.uiFeedbackStyle)
    #endif
}

#if os(iOS)
/// Generates haptic feedback with a specific style.
///
/// This function is only available on iOS platform, it generates haptic feedback using iOS's UIImpactFeedbackGenerator
///
/// - Parameter style: The style of feedback to generate, specified as a `UIImpactFeedbackGenerator.FeedbackStyle`.
func iosVibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    // Creates a UIImpactFeedbackGenerator object with the desired feedback style
    let generator = UIImpactFeedbackGenerator(style: style)
    // Generate the haptic feedback
    generator.impactOccurred()
}
#endif
