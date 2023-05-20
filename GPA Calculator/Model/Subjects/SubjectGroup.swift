// `SubjectGroup` represents a group of subjects sharing common properties and behavior
protocol SubjectGroup {
    // Returns a flat array of `Subject` included in the group
    func getSubjects() -> [Subject]
    
    // Computes GPA for subjects in the group based on the user's input
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart
}

// Extend `SubjectGroup` to support computation of GPA based on a full array of user input
extension SubjectGroup {
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart {
        computeGPA(userCourseInput: userCourseInput[0..<userCourseInput.count])
    }
}
