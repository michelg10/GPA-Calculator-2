/// A `Subject` represents a single subject group, conforming to the `SubjectGroup` protocol.
/// It contains information about the subject's name, alternative names, levels, and GPA computation details.
struct Subject: SubjectGroup {
    // Name of the subject that varies with the display size.
    let name: SizeDependentString
    // List of alternative names for the subject.
    let alternateNames: [SizeDependentString]?
    // Different levels of study that the subject can be studied at.
    let levels: [Level]
    // List of pairs mapping a score to a base GPA.
    let scoreAndBaseGPAPairs: [ScoreAndBaseGPAPair]
    
    /// Returns the names of the different levels of the subject.
    func getLevelNames() -> [String] {
        // Prepare an array to hold the level names
        var result: [String] = []
        // Iterate over levels and gather their names
        for i in levels {
            result.append(i.name)
        }
        // Return the level names
        return result
    }
    
    /// Since `Subject` is a `SubjectGroup` of a single subject, it returns itself when `getSubjects` is called.
    func getSubjects() -> [Subject] {
        return [self]
    }
    
    /// Computes the GPA based on a `UserCourseInput`.
    /// It computes a weighted GPA based on the score index and level index given in the `UserCourseInput`.
    func computeGPA(userCourseInput: UserCourseInput) -> GPAComputePart {
        return .init(value: max(scoreAndBaseGPAPairs[userCourseInput.scoreIndex].baseGPA + levels[userCourseInput.levelIndex].offset, 0), weight: levels[userCourseInput.levelIndex].weight)
    }
    
    /// Computes the GPA based on a `ArraySlice<UserCourseInput>`.
    /// Since `Subject` is a single subject, it uses the first `UserCourseInput` in the slice.
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex])
    }
}
