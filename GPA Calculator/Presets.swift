//
//  Presets.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation
import SwiftUI

enum NameMode:String, CaseIterable, Identifiable {    
    case percentage
    case letter
    
    var id: String { self.rawValue }
}

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
        self.compact=compact
        self.regular=regular
    }
    
    init(_ compact: String) {
        self.compact=compact
        self.regular=compact
    }
}

struct Course {
    var id: String
    var name: String
    var subtitle: String?
    var useSmallLevelDisplay: Bool = false
    var subjectComputeGroup: [SubjectComputeGroup]
    nonmutating func getSubjects() -> [Subject] {
        var rturn: [Subject] = []
        for i in subjectComputeGroup {
            rturn.append(contentsOf: i.getSubjects())
        }
        return rturn
    }
    lazy var subjectsCount: Int = {
        return getSubjects().count
    }()
    lazy var computedSubtitle:String = {
        if subtitle != nil {
            return subtitle!
        }
        return "\(getSubjects().count) subjects"
    }()
    func getComputedSubtitle() -> String {
        if subtitle != nil {
            return subtitle!
        }
        return "\(getSubjects().count) subjects"
    }
}

struct UserCourseInput {
    var levelIndex: Int
    var scoreIndex: Int
}

struct GPAComputePart {
    var value: Double
    var weight: Double
}

struct Level {
    var name: String
    var weight: Double
    var offset: Double
}

struct Score {
    let percentageName: String
    let letterName: String
    
    func getName(forMode nameMode: NameMode) -> String {
        switch nameMode {
        case .percentage:
            return percentageName
        case .letter:
            return letterName
        }
    }
}

struct ScoreAndBaseGPAPair {
    let score: Score
    var baseGPA: Double
    
    init(percentageName: String, letterName: String, baseGPA: Double) {
        self.score = .init(percentageName: percentageName, letterName: letterName)
        self.baseGPA = baseGPA
    }
}

protocol SubjectComputeGroup {
    func getSubjects() -> [Subject] // flatten it
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart
}

extension SubjectComputeGroup {
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart {
        computeGPA(userCourseInput: userCourseInput[0..<userCourseInput.count])
    }
}

let defaultScoreToBaseGPAMap: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "0", letterName: "F", baseGPA: 0),
    .init(percentageName:"60", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName:"68", letterName: "C+", baseGPA: 3.0),
    .init(percentageName:"73", letterName: "B-", baseGPA: 3.3),
    .init(percentageName:"78", letterName: "B", baseGPA: 3.6),
    .init(percentageName:"83", letterName: "B+", baseGPA: 3.9),
    .init(percentageName:"88", letterName: "A-", baseGPA: 4.2),
    .init(percentageName:"93", letterName: "A/A+", baseGPA: 4.5),
]

var ibScoreToBaseGPAMap: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0),
    .init(percentageName: "H4", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName: "L5", letterName: "C+", baseGPA: 3.0),
    .init(percentageName: "H5", letterName: "B-", baseGPA: 3.3),
    .init(percentageName: "L6", letterName: "B", baseGPA: 3.6),
    .init(percentageName: "H6", letterName: "B+", baseGPA: 3.9),
    .init(percentageName: "L7", letterName: "A-", baseGPA: 4.2),
    .init(percentageName: "H7", letterName: "A/A+", baseGPA: 4.5)
]

var ibOtherScoreToBaseGPAMap: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0.0),
    .init(percentageName: "D", letterName: "D", baseGPA: 0.0),
    .init(percentageName: "C", letterName: "C", baseGPA: 2.5),
    .init(percentageName: "B", letterName: "B", baseGPA: 4.0),
    .init(percentageName: "A", letterName: "A", baseGPA: 4.5)
]

struct Subject: SubjectComputeGroup {
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
        return .init(name: .init(name), alternateNames: nil, levels: [.init(name: "IB", weight: 0.5, offset: 0)], scoreAndBaseGPAPairs: ibOtherScoreToBaseGPAMap)
    }
    
    static func fastIb(name: String, alternateNames: [SizeDependentString]?=nil) -> Subject {
        return fastIb(name: SizeDependentString.init(name), alternateNames: alternateNames)
    }
    
    static func fastIb(name: SizeDependentString, alternateNames: [SizeDependentString]?=nil) -> Subject {
        return .init(name: name, alternateNames: alternateNames, levels: [.init(name: "IB", weight: 1.0, offset: 0)], scoreAndBaseGPAPairs: ibScoreToBaseGPAMap)
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
        return .init(name: .init("English"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreToBaseGPAMap)
    }
    
    static func fastChinese(weight: Double, hasHP: Bool, middleName: String, isMiddleSchoolChinese: Bool) -> Subject {
        var levels: [Level]=[]
        levels.append(.init(name: "1-2", weight: weight, offset: -0.5))
        levels.append(.init(name: "3-4", weight: weight, offset: -0.4))
        levels.append(.init(name: middleName, weight: weight, offset: -0.3))
        levels.append(.init(name: "H", weight: weight, offset: -0.2))
        if (hasHP) {
            levels.append(.init(name: "H+", weight: weight, offset: -0.1))
        }
        
        if isMiddleSchoolChinese {
            for i in 0..<levels.count {
                levels[i].offset+=0.1
            }
        }
        return .init(name: .init("Chinese"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreToBaseGPAMap)
    }
    
    static func fastOther(name: String, weight: Double, alternateNames: [SizeDependentString]?=nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double?=nil, apCustomWeight: Double?=nil) -> Subject {
        return fastOther(name: .init(name), weight: weight, alternateNames: alternateNames, hasSP: hasSP, hasH: hasH, hasAL: hasAL, hasAP: hasAP, alCustomWeight: alCustomWeight, apCustomWeight: apCustomWeight)
    }
    
    static func fastOther(name: SizeDependentString, weight: Double, alternateNames: [SizeDependentString]?=nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double?=nil, apCustomWeight: Double?=nil) -> Subject {
        var levels: [Level]=[]
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
        return .init(name: name, alternateNames: alternateNames, levels: levels, scoreAndBaseGPAPairs: defaultScoreToBaseGPAMap)
    }
}

struct maxSubjectGroup: SubjectComputeGroup {
    var subjects: [Subject]
    
    func getSubjects() -> [Subject] {
        return subjects
    }
    
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        var rturn: GPAComputePart=subjects[0].computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex])
        for i in 1..<subjects.count {
            let subjectComputePart=subjects[i].computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex+i])
            let rturnCompWeight=rturn.weight*rturn.value
            let subjectCompWeight=subjectComputePart.weight*subjectComputePart.value
            if !isEqual(rturnCompWeight, subjectCompWeight) && subjectCompWeight>rturnCompWeight {
                rturn = subjectComputePart
            }
        }
        return rturn
    }
}

struct comboSubjectGroup: SubjectComputeGroup {
    var comboMatrix: [[Double]]
    var subjects: [Subject]
    
    func getSubjects() -> [Subject] {
        return subjects
    }
    
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return .init(value: comboMatrix[userCourseInput[userCourseInput.startIndex].scoreIndex][userCourseInput[userCourseInput.startIndex+1].scoreIndex], weight: subjects[0].levels[userCourseInput[userCourseInput.startIndex].levelIndex].weight)
    }
}
