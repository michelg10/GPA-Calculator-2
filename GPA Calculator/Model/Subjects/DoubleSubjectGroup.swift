/// `DoubleSubjectGroup` represents a group of two subjects where the resulting GPA
/// is dependent on the scores of both subjects and retrieved from a 2D matrix `baseGPAMatrix`.
///
/// This struct is used when the GPA is not calculated independently from each subject's score,
/// but instead is determined by a combination of the scores from both subjects.
/// Note that the levels of the subjects in this group do not impact the resulting base GPA.
/// Offset is always considered to be 0.
/// The weight of the entire group is taken from the first level of the first subject.
struct DoubleSubjectGroup: SubjectGroup {
    // 2D matrix to look up the GPA based on scores from both subjects.
    let baseGPAMatrix: [[Double]]
    // The subjects in the group.
    let subjects: [Subject]
    
    /// Retrieves the subjects within this group.
    ///
    /// - Returns: An array of `Subject` instances in this group.
    func getSubjects() -> [Subject] {
        return subjects
    }
    
    /// Computes the GPA for the subjects based on the user's course input.
    ///
    /// The resulting GPA is dependent on the scores of both subjects and is retrieved
    /// from the 2D matrix `baseGPAMatrix`. The weight of the GPA is determined by the
    /// first level's weight of the first subject.
    ///
    /// - Parameter userCourseInput: The slice of user course input related to this group of subjects.
    /// - Returns: A `GPAComputePart` instance representing the computed GPA and its associated weight.
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return .init(value: baseGPAMatrix[userCourseInput[userCourseInput.startIndex].scoreIndex][userCourseInput[userCourseInput.startIndex + 1].scoreIndex], weight: subjects[0].levels[0].weight)
    }
}
