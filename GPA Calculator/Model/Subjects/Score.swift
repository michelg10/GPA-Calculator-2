// `Score` represents the score of a course and its different representations
struct Score {
    let percentageName: String  // The score as a percentage
    let letterName: String  // The score as a letter grade
    
    // Function to get the score name based on the desired format
    func getName(forMode nameMode: NameMode) -> String {
        switch nameMode {
        case .percentage:
            return percentageName
        case .letter:
            return letterName
        }
    }
}
