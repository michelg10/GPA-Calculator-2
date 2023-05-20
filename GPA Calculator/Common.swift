import Foundation
import SwiftUI

/// `nilButtonStyle` is a struct that implements a ButtonStyle where the button view doesn't change when being interacted with.
/// It's useful when you don't want the default button style and you're providing all of the interactive behavior in the button's content view.
struct nilButtonStyle: ButtonStyle {
    /// Returns the provided configuration's label as the view to display for the button.
    ///
    /// - Parameter configuration: The properties to use when creating the button's view.
    /// - Returns: The label of the configuration as a `some View`.
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

/// Checks if two `Double` values are approximately equal within a very small tolerance.
/// This function is useful for floating point comparisons where exact equality isn't practical.
///
/// - Parameters:
///   - a: The first `Double` value.
///   - b: The second `Double` value.
/// - Returns: `True` if `a` and `b` are approximately equal within the tolerance of `0.000001`. Otherwise, `false`.
func isEqual(_ a: Double, _ b: Double) -> Bool {
    return abs(a - b) < 0.000001
}

/// Generates haptic feedback with a specific style.
///
/// - Parameter style: The style of feedback to generate, specified as a `UIImpactFeedbackGenerator.FeedbackStyle`.
func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}
