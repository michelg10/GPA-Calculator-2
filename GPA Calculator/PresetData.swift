//
//  PresetData.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/5.
//

import Foundation

func getPresets() -> [Course] {
    let g6 = Course.init(id: "stockshsidgrade6", name: "Grade 6", subjectComputeGroup: [
        Subject.fastEnglish(weight: 6.5, hasAP: false),
        Subject.fastOther(name: "Math", weight: 6.5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastChinese(weight: 5, hasHP: false, middleName: "S", isMiddleSchoolChinese: true),
        Subject.fastChinese(weight: 5, hasHP: false, middleName: "S", isMiddleSchoolChinese: true),
        Subject.fastOther(name: "Science", weight: 2.5, hasSP: true, hasH: false, hasAL: false, hasAP: false),
        Subject.fastOther(name: "History", weight: 2.5, hasSP: true, hasH: false, hasAL: false, hasAP: false)
    ])
    
    let g7 = Course.init(id: "stockshsidgrade7", name: "Grade 7", subjectComputeGroup: [
        Subject.fastEnglish(weight: 6, hasAP: false),
        Subject.fastOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "History", weight: 5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastChinese(weight: 5, hasHP: false, middleName: "S", isMiddleSchoolChinese: true),
        Subject.fastOther(name: "Science", weight: 3, hasSP: true, hasH: false, hasAL: false, hasAP: false),
    ])
    
    let g8 = Course.init(id: "stockshsidgrade8", name: "Grade 8", subjectComputeGroup: [
        Subject.fastEnglish(weight: 6, hasAP: false),
        Subject.fastOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "Geography", weight: 5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastChinese(weight: 5, hasHP: false, middleName: "S/5-7", isMiddleSchoolChinese: true),
        Subject.fastOther(name: "Biology", weight: 3, hasSP: false, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "Physics", weight: 2.5, hasSP: false, hasH: true, hasAL: false, hasAP: false)
    ])
    
    let g9 = Course.init(id: "stockshsidgrade9", name: "Grade 9", subjectComputeGroup: [
        Subject.fastEnglish(weight: 6.5, hasAP: false),
        Subject.fastOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "History", weight: 4, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "Chemistry", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.fastChinese(weight: 3, hasHP: false, middleName: "S/5-7", isMiddleSchoolChinese: false),
        Subject.fastOther(name: "Elective", weight: 3, alternateNames: ["ITCS"], hasSP: false, hasH: true, hasAL: false, hasAP: false),
        Subject.fastOther(name: "Physics", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false)
    ])
    
    return [g6, g7, g8, g9]
}
