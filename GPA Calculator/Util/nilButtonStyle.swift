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
