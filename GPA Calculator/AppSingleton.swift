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
    var allPresets: [Course]
    var appliedPresetIndex: Int = -1
    var currentSelectedPresetIndex: Int=0
    var currentPreset: Course = .init(id: "", name: "", subjectComputeGroup: [])
    var userNameChoiceIndex: [Int]=[]
    var draftUserNameChoiceIndex: [Int]=[]
    var presetOptions: [PresetOption]=[]
    var presetOptionsCount: Int=0
    var allowGPACompute=false;
    var allowDateSave=false
    let defaults=UserDefaults.standard
    
    var userInput: [UserCourseInput] {
        didSet {
            computeGPA()
        }
    }// important: this can be bigger than it should be. simply ignore the extra elements
    var nameMode = NameMode.percentage
    
    func saveData() {
        if !allowDateSave {
            return
        }
        allowDateSave=false
        
        defaults.setValue(1, forKey: "SaveVersion")
        defaults.setValue(currentPreset.id, forKey: "PresetId")
        defaults.setValue(nameMode == .letter ? "Letter" : "Percentage", forKey: "NameMode")
        for i in 0..<currentPreset.getSubjects().count {
            defaults.setValue(userNameChoiceIndex[i], forKey: "Subject\(i)NameChoice")
            defaults.setValue(userInput[i].levelIndex, forKey: "Subject\(i)LevelIndex")
            defaults.setValue(userInput[i].scoreIndex, forKey: "Subject\(i)ScoreIndex")
        }
        
        allowDateSave=true
        defaults.synchronize()
    }
    static func defaultsHasPreset() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "SaveVersion")==nil {
            return false
        }
        let allPresets = getPresets()
        if defaults.string(forKey: "PresetId") == nil {
            return false
        }
        for i in allPresets {
            if i.id == defaults.string(forKey: "PresetId")! {
                return true
            }
        }
        return false
    }
    func reloadFromSave() {
        let presetId = defaults.string(forKey: "PresetId")!
        for i in 0..<allPresets.count {
            if allPresets[i].id == presetId {
                appliedPresetIndex = i
            }
        }
        initializeFromPresetIndex()
        allowDateSave = true
        saveData()
    }
    func initializeFromPresetIndex() {
        allowGPACompute=false
        currentPreset = allPresets[appliedPresetIndex]
        currentSelectedPresetIndex=appliedPresetIndex
        
        let presetSubjects = currentPreset.getSubjects()
        
        userInput = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: presetSubjects.count)
        userNameChoiceIndex = Array(repeating: -1, count: presetSubjects.count)
        
        var dataFailure = false
        for i in 0..<presetSubjects.count {
            let nameChoice = defaults.object(forKey: "Subject\(i)NameChoice") as? Int
            let levelIndex = defaults.object(forKey: "Subject\(i)LevelIndex") as? Int
            let scoreIndex = defaults.object(forKey: "Subject\(i)ScoreIndex") as? Int
            if nameChoice==nil||levelIndex==nil||scoreIndex==nil {
                dataFailure=true
                break
            }
            if presetSubjects[i].alternateNames == nil {
                if nameChoice != -1 {
                    dataFailure=true
                    break
                }
            } else {
                if !(nameChoice == -1 || (nameChoice!>=0&&nameChoice!<presetSubjects[i].alternateNames!.count)) {
                    dataFailure=true
                    break
                }
            }
            if !(levelIndex!>=0&&levelIndex!<presetSubjects[i].levels.count) {
                dataFailure=true
                break
            }
            if !(scoreIndex!>=0&&scoreIndex!<presetSubjects[i].scoreToBaseGPAMap.count) {
                dataFailure=true
                break
            }
            userInput[i] = .init(levelIndex: levelIndex!, scoreIndex: scoreIndex!)
            userNameChoiceIndex[i] = nameChoice!
        }
        
        if dataFailure {
            userInput = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: currentPreset.getSubjects().count)
            userNameChoiceIndex = Array(repeating: -1, count: currentPreset.getSubjects().count)
        }
        
        prepareDraftForIndex()
        allowGPACompute=true
        computeGPA()
    }
    init(loadSave: Bool) {
        allowDateSave = loadSave
        allPresets = getPresets()
        allowGPACompute=false
        userInput = []
        
        appliedPresetIndex=4 // random applied preset index for previews
        let savedNameMode = defaults.string(forKey: "NameMode")
        if savedNameMode == "Letter" {
            nameMode = .letter
        } else if savedNameMode == "Percentage" {
            nameMode = .percentage
        }
        if loadSave {
            reloadFromSave()
        } else {
            initializeFromPresetIndex()
        }
        allowGPACompute=true
    }
    func computeGPA() {
        if (!allowGPACompute) {
            return
        }
        saveData()
        var finalGPA=0.0
        var finalGPATotalWeight=0.0
        var currentUserCourseInputIndex = 0
        for i in 0..<currentPreset.subjectComputeGroup.count {
            let computeGroupSubjectCount = currentPreset.subjectComputeGroup[i].getSubjects().count
            let computeResult=currentPreset.subjectComputeGroup[i].computeGPA(userCourseInput: userInput[currentUserCourseInputIndex..<currentUserCourseInputIndex+computeGroupSubjectCount])
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
        allowGPACompute=false
        for i in 0..<userInput.count {
            userInput[i] = .init(levelIndex: 0, scoreIndex: 0)
        }
        userInput.append(contentsOf: Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: max(currentPreset.getSubjects().count-userInput.count,0)))
        allowGPACompute=true
        computeGPA()
        objectWillChange.send()
        
    }
    func prepareDraftForIndex() {
        draftUserNameChoiceIndex.append(contentsOf: Array(repeating: -1, count: max(allPresets[currentSelectedPresetIndex].getSubjects().count-draftUserNameChoiceIndex.count,0)))
        for i in 0..<draftUserNameChoiceIndex.count {
            draftUserNameChoiceIndex[i] = -1
        }
        presetOptionsCount=0
        let allSubjects = allPresets[currentSelectedPresetIndex].getSubjects()
        for i in 0..<allSubjects.count {
            if allSubjects[i].alternateNames != nil {
                let newOptionsObject = PresetOption.init(correspondingIndex: i, name: allSubjects[i].name, additionalChoicesSize: allSubjects[i].alternateNames!.count, additionalChoices: allSubjects[i].alternateNames!)
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
        userNameChoiceIndex.append(contentsOf: Array(repeating: -1, count: max(draftUserNameChoiceIndex.count-userNameChoiceIndex.count, 0)))
        for i in 0..<draftUserNameChoiceIndex.count {
            userNameChoiceIndex[i]=draftUserNameChoiceIndex[i]
        }
        if (currentSelectedPresetIndex != appliedPresetIndex) {
            appliedPresetIndex=currentSelectedPresetIndex
            currentPreset=allPresets[appliedPresetIndex]
            resetUserCourseInput()
        }
        objectWillChange.send()
    }
}
