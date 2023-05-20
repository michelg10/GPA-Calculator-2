import Foundation

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
            gpaTotalWeight += computeResult.weight;
            
            // Move the current index to the next subject group
            currentUserCourseInputIndex += computeGroupSubjectCount
        }
        
        // Final GPA is the total weighted GPA divided by the total weight
        gpa /= gpaTotalWeight
        
        return gpa
    }
}

// `UserCourseInput` represents user's input on a particular course
struct UserCourseInput {
    var levelIndex: Int  // Index of the selected level for a course
    var scoreIndex: Int  // Index of the selected score for a course
}

// `GPAComputePart` represents the result of a GPA computation
struct GPAComputePart {
    var value: Double  // The computed GPA value
    var weight: Double  // The weight assigned to this GPA computation

    // Weighted GPA value is the product of the GPA value and its corresponding weight
    var weightedValue: Double {
        return value * weight
    }
}

// `Level` represents the level of a course and its associated attributes
struct Level {
    var name: String  // The name of the level
    var weight: Double  // The weight assigned to this level
    var offset: Double  // Offset used in GPA calculation for this level
}

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

// `ScoreAndBaseGPAPair` pairs a `Score` with a base GPA value
struct ScoreAndBaseGPAPair {
    let score: Score  // The score object
    var baseGPA: Double  // The base GPA corresponding to the score
    
    init(percentageName: String, letterName: String, baseGPA: Double) {
        self.score = .init(percentageName: percentageName, letterName: letterName)
        self.baseGPA = baseGPA
    }
}

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

let defaultScoreAndBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "0", letterName: "F", baseGPA: 0),
    .init(percentageName:"60", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName:"68", letterName: "C+", baseGPA: 3.0),
    .init(percentageName:"73", letterName: "B-", baseGPA: 3.3),
    .init(percentageName:"78", letterName: "B", baseGPA: 3.6),
    .init(percentageName:"83", letterName: "B+", baseGPA: 3.9),
    .init(percentageName:"88", letterName: "A-", baseGPA: 4.2),
    .init(percentageName:"93", letterName: "A/A+", baseGPA: 4.5),
]

let ibScoreAndBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0),
    .init(percentageName: "H4", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName: "L5", letterName: "C+", baseGPA: 3.0),
    .init(percentageName: "H5", letterName: "B-", baseGPA: 3.3),
    .init(percentageName: "L6", letterName: "B", baseGPA: 3.6),
    .init(percentageName: "H6", letterName: "B+", baseGPA: 3.9),
    .init(percentageName: "L7", letterName: "A-", baseGPA: 4.2),
    .init(percentageName: "H7", letterName: "A/A+", baseGPA: 4.5)
]

let ibOtherScoreToBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0.0),
    .init(percentageName: "D", letterName: "D", baseGPA: 0.0),
    .init(percentageName: "C", letterName: "C", baseGPA: 2.5),
    .init(percentageName: "B", letterName: "B", baseGPA: 4.0),
    .init(percentageName: "A", letterName: "A", baseGPA: 4.5)
]

/// A subject group consisting of a single subject
struct Subject: SubjectGroup {
    var name: SizeDependentString
    var alternateNames: [SizeDependentString]?
    var levels: [Level]
    var scoreAndBaseGPAPairs: [ScoreAndBaseGPAPair]
    
    func getLevelNames() -> [String] {
        var rturn:[String]=[]
        for i in levels {
            rturn.append(i.name)
        }
        return rturn
    }
    
    func getSubjects() -> [Subject] {
        return [self]
    }
    
    func computeGPA(userCourseInput: UserCourseInput) -> GPAComputePart {
        return .init(value: max(scoreAndBaseGPAPairs[userCourseInput.scoreIndex].baseGPA+levels[userCourseInput.levelIndex].offset, 0), weight: levels[userCourseInput.levelIndex].weight)
    }
    
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex])
    }
    
    static func fastIbOther(name: String) -> Subject {
        return .init(name: .init(name), alternateNames: nil, levels: [.init(name: "IB", weight: 0.5, offset: 0)], scoreAndBaseGPAPairs: ibOtherScoreToBaseGPAPair)
    }
    
    static func fastIb(name: String, alternateNames: [SizeDependentString]? = nil) -> Subject {
        return fastIb(name: SizeDependentString.init(name), alternateNames: alternateNames)
    }
    
    static func fastIb(name: SizeDependentString, alternateNames: [SizeDependentString]? = nil) -> Subject {
        return .init(name: name, alternateNames: alternateNames, levels: [.init(name: "IB", weight: 1.0, offset: 0)], scoreAndBaseGPAPairs: ibScoreAndBaseGPAPair)
    }
    
    static func fastEnglish(weight: Double, hasAP: Bool) -> Subject {
        var levels: [Level]=[]
        levels.append(.init(name: "S", weight: weight, offset: -0.5))
        levels.append(.init(name: "S+", weight: weight, offset: -0.4))
        levels.append(.init(name: "H", weight: weight, offset: -0.2))
        levels.append(.init(name: "H+", weight: weight, offset: -0.1))
        if hasAP {
            levels.append(.init(name: "AP", weight: weight, offset: 0))
        }
        return .init(name: .init("English"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
    
    static func fastChinese(weight: Double, hasHP: Bool, middleLevelName: String, isMiddleSchoolChinese: Bool) -> Subject {
        var levels: [Level]=[]
        levels.append(.init(name: "1-2", weight: weight, offset: -0.5))
        levels.append(.init(name: "3-4", weight: weight, offset: -0.4))
        levels.append(.init(name: middleLevelName, weight: weight, offset: -0.3))
        levels.append(.init(name: "H", weight: weight, offset: -0.2))
        if (hasHP) {
            levels.append(.init(name: "H+", weight: weight, offset: -0.1))
        }
        
        if isMiddleSchoolChinese {
            for i in 0..<levels.count {
                levels[i].offset += 0.1
            }
        }
        return .init(name: .init("Chinese"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
    
    static func fastOther(name: String, weight: Double, alternateNames: [SizeDependentString]? = nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double? = nil, apCustomWeight: Double? = nil) -> Subject {
        return fastOther(name: .init(name), weight: weight, alternateNames: alternateNames, hasSP: hasSP, hasH: hasH, hasAL: hasAL, hasAP: hasAP, alCustomWeight: alCustomWeight, apCustomWeight: apCustomWeight)
    }
    
    static func fastOther(name: SizeDependentString, weight: Double, alternateNames: [SizeDependentString]? = nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double? = nil, apCustomWeight: Double? = nil) -> Subject {
        var levels: [Level] = []
        levels.append(.init(name: "S", weight: weight, offset: -0.5))
        if hasSP {
            levels.append(.init(name: "S+", weight: weight, offset: -0.35))
        }
        if hasH {
            levels.append(.init(name: "H", weight: weight, offset: -0.2))
        }
        if hasAL {
            levels.append(.init(name: "A-L", weight: alCustomWeight ?? weight, offset: 0))
        }
        if hasAP {
            levels.append(.init(name: "AP", weight: apCustomWeight ?? weight, offset: 0))
        }
        return .init(name: name, alternateNames: alternateNames, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
}

/// A subject group where the resulting GPA is the maximum of the GPA of the constituent subjects
struct MaxSubjectGroup: SubjectGroup {
    var subjects: [Subject]
    
    func getSubjects() -> [Subject] {
        return subjects
    }
    
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

/// A subject group where the resulting GPA is dependent on the scores of both subjects. The resulting GPA is from `baseGPAMatrix`
/// Note that the levels of the subjects in this group do not impact the resulting base GPA. Offset is taken to be 0 at all times.
/// The weight of the entire group is taken to be the weight of the first level in the first subject.
struct DoubleSubjectGroup: SubjectGroup {
    var baseGPAMatrix: [[Double]]
    var subjects: [Subject]
    
    func getSubjects() -> [Subject] {
        return subjects
    }
    
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return .init(value: baseGPAMatrix[userCourseInput[userCourseInput.startIndex].scoreIndex][userCourseInput[userCourseInput.startIndex + 1].scoreIndex], weight: subjects[0].levels[0].weight)
    }
}
