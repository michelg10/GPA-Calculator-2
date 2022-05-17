//
//  Presets.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation
enum NameMode:String, CaseIterable, Identifiable {    
    case percentage
    case letter
    
    var id: String { self.rawValue }
}
struct SizeDependentString {
    var compact: String
    var regular: String
    
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
struct ScoreToBaseGPAMap {
    var baseGPA: Double
    var percentageName: String
    var letterName: String
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
var ibScoreToBaseGPAMap: [ScoreToBaseGPAMap] = {
    var ibScoreToBaseGPAMap:[ScoreToBaseGPAMap]=[]
    ibScoreToBaseGPAMap.append(.init(baseGPA: 0, percentageName: "F", letterName: "F"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 2.6, percentageName: "H4", letterName: "C/C-"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 3.0, percentageName: "L5", letterName: "C+"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 3.3, percentageName: "H5", letterName: "B-"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 3.6, percentageName: "L6", letterName: "B"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 3.9, percentageName: "H6", letterName: "B+"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 4.2, percentageName: "L7", letterName: "A-"))
    ibScoreToBaseGPAMap.append(.init(baseGPA: 4.5, percentageName: "H7", letterName: "A/A+"))
    return ibScoreToBaseGPAMap
}()
var ibOtherScoreToBaseGPAMap: [ScoreToBaseGPAMap] = {
    var ibOtherScoreToBaseGPAMap:[ScoreToBaseGPAMap]=[]
    ibOtherScoreToBaseGPAMap.append(.init(baseGPA: 0.0, percentageName: "F", letterName: "F"))
    ibOtherScoreToBaseGPAMap.append(.init(baseGPA: 0.0, percentageName: "D", letterName: "D"))
    ibOtherScoreToBaseGPAMap.append(.init(baseGPA: 2.5, percentageName: "C", letterName: "C"))
    ibOtherScoreToBaseGPAMap.append(.init(baseGPA: 4.0, percentageName: "B", letterName: "B"))
    ibOtherScoreToBaseGPAMap.append(.init(baseGPA: 4.5, percentageName: "A", letterName: "A"))
    return ibOtherScoreToBaseGPAMap
}()
struct Subject: SubjectComputeGroup {
    var name: SizeDependentString
    var alternateNames: [SizeDependentString]?
    var levels: [Level]
    var scoreToBaseGPAMap: [ScoreToBaseGPAMap]
    
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
        return .init(value: max(scoreToBaseGPAMap[userCourseInput.scoreIndex].baseGPA+levels[userCourseInput.levelIndex].offset, 0), weight: levels[userCourseInput.levelIndex].weight)
    }
    func computeGPA(userCourseInput: ArraySlice<UserCourseInput>) -> GPAComputePart {
        return computeGPA(userCourseInput: userCourseInput[userCourseInput.startIndex])
    }
    
    static func fastIbOther(name: String) -> Subject {
        return .init(name: .init(name), alternateNames: nil, levels: [.init(name: "IB", weight: 0.5, offset: 0)], scoreToBaseGPAMap: ibOtherScoreToBaseGPAMap)
    }
    static func fastIb(name: String, alternateNames: [SizeDependentString]?=nil) -> Subject {
        return fastIb(name: SizeDependentString.init(name), alternateNames: alternateNames)
    }
    static func fastIb(name: SizeDependentString, alternateNames: [SizeDependentString]?=nil) -> Subject {
        return .init(name: name, alternateNames: alternateNames, levels: [.init(name: "IB", weight: 1.0, offset: 0)], scoreToBaseGPAMap: ibScoreToBaseGPAMap)
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
        return .init(name: .init("English"), alternateNames: nil, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
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
        return .init(name: .init("Chinese"), alternateNames: nil, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
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
        return .init(name: name, alternateNames: alternateNames, levels: levels, scoreToBaseGPAMap: defaultScoreToBaseGPAMap)
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
