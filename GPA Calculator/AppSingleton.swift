//
//  AppSingleton.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation
#if !os(macOS)
import UIKit
#endif
import SwiftUI

struct PresetOption {
    var correspondingIndex: Int
    var name: SizeDependentString
    var additionalChoicesSize: Int
    var additionalChoices: [SizeDependentString]
}
class AppSingleton:ObservableObject {
    @Published var currentGPA="0.000"
    var appliedPresetIndex: Int = -1
    var currentPreset: Course {
        presets[appliedPresetIndex]
    }
    var userNameChoiceIndex: [[Int]] = [[]]
    var presetOptions: [PresetOption] = []
    var presetOptionsCount: Int=0
    var allowDateSave=false
    let defaults=UserDefaults.standard
    
    var userInput: [[UserCourseInput]] // important: this can be bigger than it should be. simply ignore the extra elements
    var nameMode = NameMode.percentage
    
    func saveData() {
        if !allowDateSave {
            return
        }
        allowDateSave=false
        
        defaults.setValue(2, forKey: "SaveVersion")
        defaults.setValue(currentPreset.id, forKey: "PresetId")
        defaults.setValue(nameMode == .letter ? "Letter" : "Percentage", forKey: "NameMode")
        for i in 0..<presets.count {
            let presetId = presets[i].id
            let subjects = presets[i].getSubjects()
            for j in 0..<subjects.count {
                defaults.setValue(userNameChoiceIndex[i][j], forKey: "\(presetId)-\(j)-NameChoice")
                defaults.setValue(userInput[i][j].levelIndex, forKey: "\(presetId)-\(j)-LevelIndex")
                defaults.setValue(userInput[i][j].scoreIndex, forKey: "\(presetId)-\(j)-ScoreIndex")
            }
        }
        
        allowDateSave=true
    }
    static func defaultsHasPreset() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "SaveVersion")==nil {
            return false
        }
        if defaults.string(forKey: "PresetId") == nil {
            return false
        }
        for preset in presets {
            if preset.id == defaults.string(forKey: "PresetId")! {
                return true
            }
        }
        return false
    }
    func reloadFromSave() {
        let presetId = defaults.string(forKey: "PresetId")!
        for i in 0..<presets.count {
            if presets[i].id == presetId {
                appliedPresetIndex = i
            }
        }
        let saveVersion = defaults.integer(forKey: "SaveVersion")
        if saveVersion != 2 {
            // remove everything to save space
            let domain = Bundle.main.bundleIdentifier!
            defaults.removePersistentDomain(forName: domain)
            defaults.synchronize()
        }
        readUserNameChoiceAndInputFromSave()
        allowDateSave = true
        saveData()
    }
    func readUserNameChoiceAndInputFromSave() {
        for i in 0..<presets.count {
            var dataFailure = false
            let presetSubjects = presets[i].getSubjects()
            let presetId = presets[i].id
            for j in 0..<presetSubjects.count {
                let nameChoice = defaults.object(forKey: "\(presetId)-\(j)-NameChoice") as? Int
                let levelIndex = defaults.object(forKey: "\(presetId)-\(j)-LevelIndex") as? Int
                let scoreIndex = defaults.object(forKey: "\(presetId)-\(j)-ScoreIndex") as? Int
                if nameChoice==nil||levelIndex==nil||scoreIndex==nil {
                    dataFailure=true
                    break
                }
                if presetSubjects[j].alternateNames == nil {
                    if nameChoice != -1 {
                        dataFailure=true
                        break
                    }
                } else {
                    if !(nameChoice == -1 || (nameChoice!>=0&&nameChoice!<presetSubjects[j].alternateNames!.count)) {
                        dataFailure=true
                        break
                    }
                }
                if !(levelIndex!>=0&&levelIndex!<presetSubjects[j].levels.count) {
                    dataFailure=true
                    break
                }
                if !(scoreIndex!>=0&&scoreIndex!<presetSubjects[j].scoreToBaseGPAMap.count) {
                    dataFailure=true
                    break
                }
                userInput[i][j] = .init(levelIndex: levelIndex!, scoreIndex: scoreIndex!)
                userNameChoiceIndex[i][j] = nameChoice!
            }
            if dataFailure {
                userInput[i] = .init(repeating: .init(levelIndex: 0, scoreIndex: 0), count: userInput[i].count)
                userNameChoiceIndex[i] = .init(repeating: -1, count: userNameChoiceIndex[i].count)
            }
        }

        prepareDraftForIndex()
        computeGPA()
    }
    init(loadSave: Bool) {
        allowDateSave = loadSave
        userInput = []
        
        appliedPresetIndex=4 // random applied preset index for previews
        let savedNameMode = defaults.string(forKey: "NameMode")
        if savedNameMode == "Letter" {
            nameMode = .letter
        } else if savedNameMode == "Percentage" {
            nameMode = .percentage
        }
        
        
        // initializing user course input and user name choices
        userInput = Array(repeating: [], count: presets.count)
        userNameChoiceIndex = Array(repeating: [], count: presets.count)
        var maxRequiredSize = 0 // maximum required size to hold name choices for any preset
        for i in 0..<userNameChoiceIndex.count {
            let presetSubjectCount = presets[i].subjectsCount
            maxRequiredSize = max(maxRequiredSize, presetSubjectCount)
        }
        for i in 0..<userNameChoiceIndex.count {
            userInput[i] = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: maxRequiredSize)
            userNameChoiceIndex[i] = Array(repeating: -1, count: maxRequiredSize)
        }
        
        if loadSave {
            reloadFromSave()
        } else {
            readUserNameChoiceAndInputFromSave()
        }        
    }
    
    func computeGPA() {
        saveData()
        if appliedPresetIndex == -1 {
            assertionFailure("Applied preset index is -1!")
            return
        }
        var finalGPA=0.0
        var finalGPATotalWeight=0.0
        var currentUserCourseInputIndex = 0
        for i in 0..<currentPreset.subjectComputeGroup.count {
            let computeGroupSubjectCount = currentPreset.subjectComputeGroup[i].getSubjects().count
            let computeResult=currentPreset.subjectComputeGroup[i].computeGPA(userCourseInput: userInput[appliedPresetIndex][currentUserCourseInputIndex..<currentUserCourseInputIndex+computeGroupSubjectCount])
            finalGPA+=computeResult.value*computeResult.weight;
            finalGPATotalWeight+=computeResult.weight;
            currentUserCourseInputIndex+=computeGroupSubjectCount
        }
        finalGPA/=finalGPATotalWeight
        var finalGPAString=String(Int(round(finalGPA*1000)))
        while finalGPAString.count<4 {
            finalGPAString.insert("0", at: finalGPAString.startIndex)
        }
        currentGPA=finalGPAString[finalGPAString.startIndex..<finalGPAString.index(finalGPAString.endIndex, offsetBy: -3)]+"."+finalGPAString[finalGPAString.index(finalGPAString.endIndex, offsetBy: -3)..<finalGPAString.endIndex]
    }
    
    func resetUserCourseInput() {
        for i in 0..<userInput[appliedPresetIndex].count {
            userInput[appliedPresetIndex][i] = .init(levelIndex: 0, scoreIndex: 0)
        }
        computeGPA()
        objectWillChange.send()
    }
    func prepareDraftForIndex() {
        presetOptionsCount=0
        let subjects = presets[appliedPresetIndex].getSubjects()
        for i in 0..<subjects.count {
            if subjects[i].alternateNames != nil {
                let newOptionsObject = PresetOption.init(correspondingIndex: i, name: subjects[i].name, additionalChoicesSize: subjects[i].alternateNames!.count, additionalChoices: subjects[i].alternateNames!)
                if presetOptionsCount>=presetOptions.count {
                    presetOptions.append(newOptionsObject)
                } else {
                    presetOptions[presetOptionsCount].correspondingIndex=newOptionsObject.correspondingIndex
                    presetOptions[presetOptionsCount].name=newOptionsObject.name
                    presetOptions[presetOptionsCount].additionalChoices.append(contentsOf: Array(repeating: .init(""), count: max(newOptionsObject.additionalChoicesSize-presetOptions[presetOptionsCount].additionalChoices.count,0)))
                    presetOptions[presetOptionsCount].additionalChoicesSize = newOptionsObject.additionalChoicesSize
                    for j in 0..<newOptionsObject.additionalChoicesSize {
                        presetOptions[presetOptionsCount].additionalChoices[j]=newOptionsObject.additionalChoices[j]
                    }
                }
                presetOptionsCount+=1
            }
        }
        
        objectWillChange.send()
    }
    
    func applySelection() {
        computeGPA()
        objectWillChange.send()
    }
}
