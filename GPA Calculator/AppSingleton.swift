import Foundation
#if !os(macOS)
import UIKit
#endif
import SwiftUI

// `PresetOption` represents an option for customizing the name of a single subject in the Customize view.
struct PresetOption {
    // `correspondingIndex` holds the index into the array `alternativeNamePreferenceIndex[currentPresetIndex]`.
    // This link to the model data allows us to update and track the user's preferred name choice for this subject.
    var correspondingIndex: Int

    // `name` is a default identifier for the subject. This identifier adjusts its display
    // depending on the size class of the user interface (for example, regular or compact layouts).
    var name: SizeDependentString

    // `additionalChoicesSize` records the actual count of additional name choices for the subject.
    // To prevent out-of-range index errors during SwiftUI view updates, which can lag behind model data changes,
    // the `additionalChoices` array is often made larger than the real data set it represents.
    // Thus, `additionalChoicesSize` serves as a reliable source for the true data count.
    var additionalChoicesSize: Int

    // `additionalChoices` is an array holding alternative names for the subject.
    // Each element in the array is a `SizeDependentString` that adjusts its display to the size class of the user interface.
    var additionalChoices: [SizeDependentString]
}

class AppSingleton:ObservableObject {
    @Published var currentGPA = "0.000"
    
    var currentPresetIndex: Int = -1
    var currentPreset: Preset {
        presets[currentPresetIndex]
    }
    
    // Records the user's preference for alternative names of subjects for all presets
    var alternativeNamePreferenceIndex: [[Int]] = [[]]
    
    // Records the preset options for each subject for the currently selected preset in the customize view.
    // This is usually larger than required to prevent out-of-range index errors during SwiftUI view updates, which can lag behind model data changes,
    // so an additional `presetOptionsCount` is required to keep track of the true data count
    var presetOptions: [PresetOption] = []
    var presetOptionsCount: Int = 0
    
    // To prevent multiple save attempts happening at the same time
    var allowDateSave = false
    let defaults = UserDefaults.standard
    
    // The user input for each subject in every preset. This can also be bigger than required to prevent out-of-range index errors during SwiftUI view updates;
    // simply ignore the extra elements
    var userInput: [[UserCourseInput]]
    
    // The user's preference regarding the format to display the scores
    var nameMode = NameMode.percentage
    
    func saveData() {
        if !allowDateSave {
            return
        }
        allowDateSave = false
        defer {
            allowDateSave = true
        }
        
        defaults.setValue(2, forKey: "SaveVersion")
        defaults.setValue(currentPreset.id, forKey: "PresetId")
        defaults.setValue(nameMode == .letter ? "Letter" : "Percentage", forKey: "NameMode")
        for i in 0..<presets.count {
            let presetId = presets[i].id
            let subjects = presets[i].subjects
            for j in 0..<subjects.count {
                defaults.setValue(alternativeNamePreferenceIndex[i][j], forKey: "\(presetId)-\(j)-NameChoice")
                defaults.setValue(userInput[i][j].levelIndex, forKey: "\(presetId)-\(j)-LevelIndex")
                defaults.setValue(userInput[i][j].scoreIndex, forKey: "\(presetId)-\(j)-ScoreIndex")
            }
        }
    }
    
    static func currentPresetInSaveIsValid() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "SaveVersion") == nil {
            return false
        }
        
        // PresetId stores the ID of the user's currently selected preset
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
                currentPresetIndex = i
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
            var loadFailure = false
            let presetSubjects = presets[i].subjects
            let presetId = presets[i].id
            for j in 0..<presetSubjects.count {
                let nameChoice = defaults.object(forKey: "\(presetId)-\(j)-NameChoice") as? Int
                let levelIndex = defaults.object(forKey: "\(presetId)-\(j)-LevelIndex") as? Int
                let scoreIndex = defaults.object(forKey: "\(presetId)-\(j)-ScoreIndex") as? Int
                
                // Run sanity checks
                guard let nameChoice = nameChoice, let levelIndex = levelIndex, let scoreIndex = scoreIndex else {
                    loadFailure = true
                    break
                }
                
                if presetSubjects[j].alternateNames == nil {
                    if nameChoice != -1 {
                        loadFailure = true
                        break
                    }
                } else {
                    if !(nameChoice == -1 || (nameChoice >= 0 && nameChoice < presetSubjects[j].alternateNames!.count)) {
                        loadFailure=true
                        break
                    }
                }
                
                if !(levelIndex >= 0 && levelIndex < presetSubjects[j].levels.count) {
                    loadFailure=true
                    break
                }
                
                if !(scoreIndex >= 0 && scoreIndex < presetSubjects[j].scoreAndBaseGPAPairs.count) {
                    loadFailure=true
                    break
                }
                userInput[i][j] = .init(levelIndex: levelIndex, scoreIndex: scoreIndex)
                alternativeNamePreferenceIndex[i][j] = nameChoice
            }
            if loadFailure {
                userInput[i] = .init(repeating: .init(levelIndex: 0, scoreIndex: 0), count: userInput[i].count)
                alternativeNamePreferenceIndex[i] = .init(repeating: -1, count: alternativeNamePreferenceIndex[i].count)
            }
        }

        initializePresetOptionsForCurrentPresetIndex()
        computeGPA()
    }
    
    init(loadSave: Bool) {
        allowDateSave = loadSave
        userInput = []
        
        currentPresetIndex = 4 // random applied preset index for previews
        let savedNameMode = defaults.string(forKey: "NameMode")
        if savedNameMode == "Letter" {
            nameMode = .letter
        } else if savedNameMode == "Percentage" {
            nameMode = .percentage
        }
        
        
        // initializing user course input and user name choices
        userInput = Array(repeating: [], count: presets.count)
        alternativeNamePreferenceIndex = Array(repeating: [], count: presets.count)
        var maxRequiredSize = 0 // maximum required size to hold name choices for any preset.
        // The user input array for every preset will be initialized to this size to prevent out-of-bounds errors from happening as SwiftUI view updates might be out of sync with model updates
        for i in 0..<alternativeNamePreferenceIndex.count {
            let presetSubjectCount = presets[i].subjects.count
            maxRequiredSize = max(maxRequiredSize, presetSubjectCount)
        }
        
        for i in 0..<alternativeNamePreferenceIndex.count {
            userInput[i] = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: maxRequiredSize)
            alternativeNamePreferenceIndex[i] = Array(repeating: -1, count: maxRequiredSize)
        }
        
        if loadSave {
            reloadFromSave()
        } else {
            readUserNameChoiceAndInputFromSave()
        }        
    }
    
    func formatDoubleToDecimalPlaces(_ value: Double, decimalPlaces: Int) -> String {
        var roundedString = String(Int(round(value * pow(10, Double(decimalPlaces)))))
        
        // if the length is less than `decimalPlaces+1`, then it means that it's a decimal with that's less than zero
        // (for example, 0.2 will become 200 with decimalPlaces=3).
        // Therefore, we should add zeros until length = decimalPlaces + 1 to properly "normalize" the results
        while roundedString.count < decimalPlaces + 1 {
            roundedString.insert("0", at: roundedString.startIndex)
        }
        let firstDecimalPlace = roundedString.index(roundedString.endIndex, offsetBy: -3)
        let roundedStringWithDecimalPoint = roundedString[roundedString.startIndex ..< firstDecimalPlace] + "." + roundedString[firstDecimalPlace ..< roundedString.endIndex]
        
        return String(roundedStringWithDecimalPoint)
    }
    
    func computeGPA() {
        saveData()
        
        if currentPresetIndex == -1 {
            assertionFailure("Applied preset index is -1!")
            return
        }
        
        currentGPA = formatDoubleToDecimalPlaces(currentPreset.computeGPA(userCourseInput: userInput[currentPresetIndex]), decimalPlaces: 3)
    }
    
    func resetUserCourseInput() {
        for i in 0..<userInput[currentPresetIndex].count {
            userInput[currentPresetIndex][i] = .init(levelIndex: 0, scoreIndex: 0)
        }
        computeGPA()
        objectWillChange.send()
    }
    
    func initializePresetOptionsForCurrentPresetIndex() {
        presetOptionsCount = 0
        let subjects = presets[currentPresetIndex].subjects
        
        for i in 0..<subjects.count {
            if subjects[i].alternateNames != nil {
                let newOptionsObject = PresetOption.init(correspondingIndex: i, name: subjects[i].name, additionalChoicesSize: subjects[i].alternateNames!.count, additionalChoices: subjects[i].alternateNames!)
                if presetOptionsCount >= presetOptions.count {
                    presetOptions.append(newOptionsObject)
                } else {
                    presetOptions[presetOptionsCount].correspondingIndex = newOptionsObject.correspondingIndex
                    presetOptions[presetOptionsCount].name = newOptionsObject.name
                    presetOptions[presetOptionsCount].additionalChoices.append(contentsOf: Array(repeating: .init(""), count: max(newOptionsObject.additionalChoicesSize-presetOptions[presetOptionsCount].additionalChoices.count,0)))
                    presetOptions[presetOptionsCount].additionalChoicesSize = newOptionsObject.additionalChoicesSize
                    for j in 0..<newOptionsObject.additionalChoicesSize {
                        presetOptions[presetOptionsCount].additionalChoices[j] = newOptionsObject.additionalChoices[j]
                    }
                }
                presetOptionsCount += 1
            }
        }
        
        objectWillChange.send()
    }
    
    func recomputeGPA() {
        computeGPA()
        objectWillChange.send()
    }
    
    func update() {
        objectWillChange.send()
    }
}
