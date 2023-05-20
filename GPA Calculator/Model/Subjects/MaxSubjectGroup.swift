/// `MaxSubjectGroup` represents a group of subjects where the resulting GPA
/// is the maximum of the GPAs of the constituent subjects.
///
/// This struct can be used in scenarios where you want to take a group of subjects
/// and treat them as a unit for GPA calculation purposes, but only the highest GPA among them
/// contributes to the overall GPA.
struct MaxSubjectGroup: SubjectGroup {
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
    /// The resulting GPA is the maximum of the GPAs of the subjects in the group.
    /// This method iterates through the subjects, computes the GPA for each one,
    /// and updates the resulting GPA if the computed GPA is greater.
    ///
    /// - Parameter userCourseInput: The slice of user course input related to this group of subjects.
    /// - Returns: A `GPAComputePart` instance representing the computed GPA and its associated weight.
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        var resultingComputePart: GPAComputePart = subjects[0].computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex])
        for i in 1..<subjects.count {
            let subjectComputePart = subjects[i].computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex+i])
            let resultWeighted = resultingComputePart.weightedValue
            let subjectWeighted = subjectComputePart.weightedValue
            if !isEqual(resultWeighted, subjectWeighted) && subjectWeighted > resultWeighted {
                resultingComputePart = subjectComputePart
            }
        }
        return resultingComputePart
    }
}
