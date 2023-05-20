import SwiftUI

/// `SizeDependentString` is a struct that holds two versions of a string, `compact` and `regular`,
/// and can return the appropriate one based on the given horizontal user interface size class.
struct SizeDependentString {
    let compact: String  // Represents the compact version of the string.
    let regular: String  // Represents the regular version of the string.
    
    /// Returns the string appropriate for the given horizontal user interface size class.
    ///
    /// - Parameter horizontalUserInterfaceSizeClass: The current horizontal user interface size class.
    /// - Returns: The `compact` string if the size class is `.compact`; the `regular` string otherwise.
    func getStringFor(horizontalUserInterfaceSizeClass: UserInterfaceSizeClass?) -> String {
        guard let horizontalUserInterfaceSizeClass = horizontalUserInterfaceSizeClass else {
            return regular
        }
        
        switch horizontalUserInterfaceSizeClass {
        case .compact:
            return compact
        case .regular:
            return regular
        @unknown default:
            return regular
        }
    }
    
    /// Initializes a new `SizeDependentString` with specified `compact` and `regular` versions of the string.
    ///
    /// - Parameters:
    ///   - compact: The string to use for a compact horizontal user interface size class.
    ///   - regular: The string to use for a regular horizontal user interface size class.
    init(_ compact: String, _ regular:String) {
        self.compact = compact
        self.regular = regular
    }
    
    /// Initializes a new `SizeDependentString` with a single string that is used for both `compact` and `regular` versions.
    ///
    /// - Parameter compact: The string to use for both compact and regular horizontal user interface size classes.
    init(_ compact: String) {
        self.compact = compact
        self.regular = compact
    }
}
