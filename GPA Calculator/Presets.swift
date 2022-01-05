//
//  Presets.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation
enum NameMode {
    case percentage
    case letter
}
struct Course {
    var id: String
    var name: String
    var subtitle: String?
    var subjectComputeGroup: [SubjectComputeGroup]
    func getSubjects() -> [Subject] {
        var rturn: [Subject] = []
        for i in subjectComputeGroup {
            rturn.append(contentsOf: i.getSubjects())
        }
        return rturn
    }
    lazy var computedSubtitle:String = {
        if subtitle != nil {
            return subtitle!
        }
        return "\(getSubjects().count) subjects"
    }()
}
struct UserCourseInput {
    var levelIndex: Int
    var scoreIndex: Int
}
struct GPAComputePart {
    var value: Float
    var weight: Float
}
struct Level {
    var name: String
    var weight: Float
    var offset: Float
}
struct ScoreToBaseGPAMap {
    var baseGPA: Float
    var percentageName: String
    var letterName: String
}
protocol SubjectComputeGroup {
    func getSubjects() -> [Subject] // flatten it
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart
}
var defaultScoreToBaseGPAMap: [ScoreToBaseGPAMap] = {
    var defaultScoreToBaseGPAMap:[ScoreToBaseGPAMap]=[]
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 0, percentageName:"0", letterName: "F"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 2.6, percentageName:"60", letterName: "C/C-"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 3.0, percentageName:"68", letterName: "C+"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 3.3, percentageName:"73", letterName: "B-"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 3.6, percentageName:"78", letterName: "B"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 3.9, percentageName:"83", letterName: "B+"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 4.2, percentageName:"88", letterName: "A-"))
    defaultScoreToBaseGPAMap.append(ScoreToBaseGPAMap(baseGPA: 4.5, percentageName:"93", letterName: "A/A+"))
    return defaultScoreToBaseGPAMap
}()
struct Subject: SubjectComputeGroup {
    var name: String
    var alternateNames: [String]?
    var levels: [Level]
    var scoreToBaseGPAMap: [ScoreToBaseGPAMap]
    
    func getSubjects() -> [Subject] {
        return [self]
    }
    func computeGPA(userCourseInput: UserCourseInput) -> GPAComputePart {
        return .init(value: max(scoreToBaseGPAMap[userCourseInput.scoreIndex].baseGPA+levels[userCourseInput.levelIndex].offset, 0), weight: levels[userCourseInput.levelIndex].weight)
    }
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart {
        return computeGPA(userCourseInput: userCourseInput[0])
    }
    
    static func fastEnglish(weight: Float, hasAP: Bool) -> Subject {
        var levels: [Level]=[]
        levels.append(.init(name: "S", weight: weight, offset: -0.5))
        levels.append(.init(name: "S+", weight: weight, offset: -0.4))
        levels.append(.init(name: "H", weight: weight, offset: -0.2))
        levels.append(.init(name: "H+", weight: weight, offset: -0.1))
        if hasAP {
            levels.append(.init(name: "AP", weight: weight, offset: 0))
        }
        return .init(name: "English", alternateNames: nil, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
    }
    static func fastChinese(weight: Float, hasHP: Bool, middleName: String, isMiddleSchoolChinese: Bool) -> Subject {
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
        return .init(name: "Chinese", alternateNames: nil, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
    }
    static func fastOther(name: String, weight: Float, alternateNames: [String]?=nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Float?=nil, apCustomWeight: Float?=nil) -> Subject {
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
        return .init(name: name, alternateNames: alternateNames, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
    }
}
struct maxSubjectGroup: SubjectComputeGroup {
    var subjects: [Subject]
    
    func getSubjects() -> [Subject] {
        return subjects
    }
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart {
        var rturn: GPAComputePart=subjects[0].computeGPA(userCourseInput: userCourseInput[0])
        for i in 1..<subjects.count {
            let subjectComputePart=subjects[i].computeGPA(userCourseInput: userCourseInput[i])
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
    var comboMatrix: [[Float]]
    var subjects: [Subject]
    func getSubjects() -> [Subject] {
        return subjects
    }
    func computeGPA(userCourseInput: [UserCourseInput]) -> GPAComputePart {
        return .init(value: comboMatrix[userCourseInput[0].scoreIndex][userCourseInput[1].scoreIndex], weight: subjects[0].levels[userCourseInput[0].levelIndex].weight)
    }
}
