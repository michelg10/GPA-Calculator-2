import SwiftUI

struct SizeDependentString {
    var compact: String
    var regular: String
    
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
    
    init(_ compact: String, _ regular:String) {
        self.compact = compact
        self.regular = regular
    }
    
    init(_ compact: String) {
        self.compact = compact
        self.regular = compact
    }
}
