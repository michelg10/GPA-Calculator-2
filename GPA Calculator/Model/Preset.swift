/// `Preset` represents a predefined set of courses (subjects) for GPA computation.
struct Preset {
    let id: String  // Unique identifier for the preset
    let name: String  // Human-readable name of the preset
    
    // Flag to determine if the UI should use a smaller control for displaying course levels.
    // This is typically used for courses that only have a single level, like IB courses.
    let useSmallLevelDisplay: Bool
    
    let subjectGroups: [SubjectGroup]  // Grouping of subjects that belong to the preset
    
    // Computed Properties
    // A flat list of all subjects in the preset, regardless of their group
    let subjects: [Subject]
    
    // A description or subtitle for the preset, could be a summary or additional info
    let subtitle: String
    
    /// Initializes a new `Preset`.
    ///
    /// - Parameters:
    ///     - id: A string that uniquely identifies the preset.
    ///     - name: A human-readable name for the preset.
    ///     - subtitle: An optional string used as a subtitle or description for the preset.
    ///     - useSmallLevelDisplay: A Boolean indicating whether to use small display for course levels. Defaults to `false`.
    ///     - subjectComputeGroups: An array of `SubjectGroup` that defines the subject groups of the preset.
    init(id: String, name: String, subtitle: String? = nil, useSmallLevelDisplay: Bool = false, subjectComputeGroups: [SubjectGroup]) {
        self.id = id
        self.name = name
        self.useSmallLevelDisplay = useSmallLevelDisplay
        self.subjectGroups = subjectComputeGroups
        
        // Populate the flat list of subjects
        var subjects: [Subject] = []
        for subjectComputeGroup in subjectComputeGroups {
            subjects.append(contentsOf: subjectComputeGroup.getSubjects())
        }
        self.subjects = subjects
        
        // If a subtitle is not provided, default to a string with the count of subjects
        self.subtitle = subtitle ?? "\(subjects.count) subjects"
    }
    
    /// Computes the GPA for the preset, given the user's course inputs.
    ///
    /// - Parameter userCourseInput: An array of `UserCourseInput` that represents the user's inputs for the courses.
    /// - Returns: A `Double` representing the computed GPA.
    func computeGPA(userCourseInput: [UserCourseInput]) -> Double {
        var gpa = 0.0
        var gpaTotalWeight = 0.0
        var currentUserCourseInputIndex = 0
        
        // Loop over each subject group and compute the GPA for each
        for i in 0..<subjectGroups.count {
            let computeGroupSubjectCount = subjectGroups[i].getSubjects().count
            let computeResult = subjectGroups[i].computeGPA(userCourseInput: userCourseInput[currentUserCourseInputIndex..<currentUserCourseInputIndex+computeGroupSubjectCount])
            
            // Accumulate the weighted GPA and the total weight
            gpa += computeResult.weightedValue
            gpaTotalWeight += computeResult.weight
            
            // Move the current index to the next subject group
            currentUserCourseInputIndex += computeGroupSubjectCount
        }
        
        // Final GPA is the total weighted GPA divided by the total weight
        gpa /= gpaTotalWeight
        
        return gpa
    }
}
