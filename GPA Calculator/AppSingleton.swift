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

/// `AppSingleton` is a singleton class that manages application-wide state data. This includes methods for persisting
/// and restoring state from UserDefaults, and triggering UI updates when state changes.
class AppSingleton: ObservableObject {

    // The currently calculated GPA, as a String formatted to three decimal places.
    @Published var currentGPA = "0.000"
    
    // The index of the currently selected Preset.
    var currentPresetIndex: Int = -1
    
    // A shortcut for accessing the currently selected Preset from the list of all Presets.
    var currentPreset: Preset {
        presets[currentPresetIndex]
    }
    
    // A two-dimensional array representing the user's preference for alternative names of subjects for each Preset.
    var alternativeNamePreferenceIndex: [[Int]] = [[]]
    
    // Array of `PresetOption` objects, representing the preset options for each subject for the currently selected preset in the Customize View.
    var presetOptions: [PresetOption] = []
    var presetOptionsCount: Int = 0
    
    // Boolean flag used to prevent multiple save attempts from happening concurrently.
    var allowDateSave = false
    let defaults = UserDefaults.standard
    
    // A two-dimensional array representing the user's input for each subject in every Preset.
    var userInput: [[UserCourseInput]]
    
    // The user's preferred format for displaying scores (percentage or letter).
    var nameMode = NameMode.percentage
    
    // This function saves the application's current state to UserDefaults
    func saveData() {
        // If saving is not currently allowed, immediately return
        if !allowDateSave {
            return
        }
        // Temporarily disallow saving
        allowDateSave = false
        // After the function completes (successfully or not), reallow saving
        defer {
            allowDateSave = true
        }
        
        // Store the current save version
        defaults.setValue(2, forKey: "SaveVersion")
        // Store the ID of the current preset
        defaults.setValue(currentPreset.id, forKey: "PresetId")
        // Store the user's preferred score display mode
        defaults.setValue(nameMode == .letter ? "Letter" : "Percentage", forKey: "NameMode")
        // Iterate over all presets
        for i in 0..<presets.count {
            let presetId = presets[i].id
            let subjects = presets[i].subjects
            // Iterate over all subjects in the current preset
            for j in 0..<subjects.count {
                // Store the user's alternative name preference for each subject
                defaults.setValue(alternativeNamePreferenceIndex[i][j], forKey: "\(presetId)-\(j)-NameChoice")
                // Store the user's level input for each subject
                defaults.setValue(userInput[i][j].levelIndex, forKey: "\(presetId)-\(j)-LevelIndex")
                // Store the user's score input for each subject
                defaults.setValue(userInput[i][j].scoreIndex, forKey: "\(presetId)-\(j)-ScoreIndex")
            }
        }
    }

    // This static function checks if a valid preset currently exists in UserDefaults
    static func currentPresetInSaveIsValid() -> Bool {
        let defaults = UserDefaults.standard
        // If no save version is found, the preset in save is invalid
        if defaults.object(forKey: "SaveVersion") == nil {
            return false
        }
        
        // If no current preset ID is found, the preset in save is invalid
        if defaults.string(forKey: "PresetId") == nil {
            return false
        }
        
        // Check all presets to see if any of them match the saved preset ID
        for preset in presets {
            if preset.id == defaults.string(forKey: "PresetId")! {
                // If a match is found, the preset in save is valid
                return true
            }
        }
        
        // If no matches are found, the preset in save is invalid
        return false
    }

    // This function reloads the application state from UserDefaults
    func reloadFromSave() {
        let presetId = defaults.string(forKey: "PresetId")!
        // Find the preset that matches the saved preset ID
        for i in 0..<presets.count {
            if presets[i].id == presetId {
                // Update the current preset index to the found preset
                currentPresetIndex = i
            }
        }
        let saveVersion = defaults.integer(forKey: "SaveVersion")
        if saveVersion != 2 {
            // If the saved version is not 2, clear all saved data to prevent conflicts or crashes
            let domain = Bundle.main.bundleIdentifier!
            defaults.removePersistentDomain(forName: domain)
            defaults.synchronize()
        }
        // Apply user's saved name choice and input
        readUserNameChoiceAndInputFromSave()
        // Allow data saving again
        allowDateSave = true
        // Save the current state to ensure consistency
        saveData()
    }
    
    // This function reads the user's name choice and input from UserDefaults
    func readUserNameChoiceAndInputFromSave() {
        // Loop over all presets
        for i in 0..<presets.count {
            // Initialize a flag for load failures
            var loadFailure = false
            let presetSubjects = presets[i].subjects
            let presetId = presets[i].id
            // Loop over all subjects within a preset
            for j in 0..<presetSubjects.count {
                // Attempt to retrieve the user's saved inputs
                let nameChoice = defaults.object(forKey: "\(presetId)-\(j)-NameChoice") as? Int
                let levelIndex = defaults.object(forKey: "\(presetId)-\(j)-LevelIndex") as? Int
                let scoreIndex = defaults.object(forKey: "\(presetId)-\(j)-ScoreIndex") as? Int
                
                // Ensure the saved inputs exist and are valid
                guard let nameChoice = nameChoice, let levelIndex = levelIndex, let scoreIndex = scoreIndex else {
                    loadFailure = true
                    break
                }
                
                // Check if alternate names exist and are valid
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
                
                // Check if the level index is within range
                if !(levelIndex >= 0 && levelIndex < presetSubjects[j].levels.count) {
                    loadFailure=true
                    break
                }
                
                // Check if the score index is within range
                if !(scoreIndex >= 0 && scoreIndex < presetSubjects[j].scoreAndBaseGPAPairs.count) {
                    loadFailure=true
                    break
                }
                // If all checks passed, save the user input and name choice
                userInput[i][j] = .init(levelIndex: levelIndex, scoreIndex: scoreIndex)
                alternativeNamePreferenceIndex[i][j] = nameChoice
            }
            // If a load failure occurred, reset the user input and name choice for this preset
            if loadFailure {
                userInput[i] = .init(repeating: .init(levelIndex: 0, scoreIndex: 0), count: userInput[i].count)
                alternativeNamePreferenceIndex[i] = .init(repeating: -1, count: alternativeNamePreferenceIndex[i].count)
            }
        }
        // Set up the preset options for the current preset and calculate the GPA
        initializePresetOptionsForCurrentPresetIndex()
        computeGPA()
    }

    // The constructor that initializes the state of the application
    init(loadSave: Bool) {
        // Set whether data saving is allowed based on the input argument
        allowDateSave = loadSave
        userInput = []
        
        // Apply a preset index for previews
        currentPresetIndex = 4
        let savedNameMode = defaults.string(forKey: "NameMode")
        // Set the name mode based on the saved preference
        if savedNameMode == "Letter" {
            nameMode = .letter
        } else if savedNameMode == "Percentage" {
            nameMode = .percentage
        }
        
        // Initialize user course input and user name choices
        userInput = Array(repeating: [], count: presets.count)
        alternativeNamePreferenceIndex = Array(repeating: [], count: presets.count)
        // The maximum required size to hold name choices for any preset. The user input array for every preset will be initialized to this size to prevent out-of-bounds errors
        var maxRequiredSize = 0
        for i in 0..<alternativeNamePreferenceIndex.count {
            let presetSubjectCount = presets[i].subjects.count
            maxRequiredSize = max(maxRequiredSize, presetSubjectCount)
        }
        
        // Initialize userInput and alternativeNamePreferenceIndex arrays with default values
        for i in 0..<alternativeNamePreferenceIndex.count {
            userInput[i] = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: maxRequiredSize)
            alternativeNamePreferenceIndex[i] = Array(repeating: -1, count: maxRequiredSize)
        }
        
        // If loadSave is true, reload data from saved state, else read user name choice and input from saved state
        if loadSave {
            reloadFromSave()
        } else {
            readUserNameChoiceAndInputFromSave()
        }
    }
    
    // This function formats a Double to a specific number of decimal places
    func formatDoubleToDecimalPlaces(_ value: Double, decimalPlaces: Int) -> String {
        // Convert the Double to a rounded String with specific decimal places
        var roundedString = String(Int(round(value * pow(10, Double(decimalPlaces)))))
        
        // In case the roundedString's count is less than decimalPlaces+1, we add zeros to the start
        // to ensure the decimal accuracy
        while roundedString.count < decimalPlaces + 1 {
            roundedString.insert("0", at: roundedString.startIndex)
        }
        // Insert decimal point in the appropriate place
        let firstDecimalPlace = roundedString.index(roundedString.endIndex, offsetBy: -3)
        let roundedStringWithDecimalPoint = roundedString[roundedString.startIndex ..< firstDecimalPlace] + "." + roundedString[firstDecimalPlace ..< roundedString.endIndex]
        
        // Return the rounded string with correct decimal places
        return String(roundedStringWithDecimalPoint)
    }

    // This function calculates the GPA based on the current preset
    func computeGPA() {
        // Save the current data
        saveData()
        
        // Ensure the preset index is valid
        if currentPresetIndex == -1 {
            assertionFailure("Applied preset index is -1!")
            return
        }
        
        // Calculate and format the GPA with 3 decimal places
        currentGPA = formatDoubleToDecimalPlaces(currentPreset.computeGPA(userCourseInput: userInput[currentPresetIndex]), decimalPlaces: 3)
    }

    // This function resets the user's course input
    func resetUserCourseInput() {
        // Reset all inputs for the current preset
        for i in 0..<userInput[currentPresetIndex].count {
            userInput[currentPresetIndex][i] = .init(levelIndex: 0, scoreIndex: 0)
        }
        // Recalculate the GPA and update the UI
        computeGPA()
        objectWillChange.send()
    }

    // This function initializes the preset options for the current preset index
    func initializePresetOptionsForCurrentPresetIndex() {
        // Reset the count of preset options
        presetOptionsCount = 0
        let subjects = presets[currentPresetIndex].subjects
        
        // Iterate over all subjects in the current preset
        for i in 0..<subjects.count {
            // If the subject has alternate names, prepare the preset option object
            if subjects[i].alternateNames != nil {
                let newOptionsObject = PresetOption.init(correspondingIndex: i, name: subjects[i].name, additionalChoicesSize: subjects[i].alternateNames!.count, additionalChoices: subjects[i].alternateNames!)
                // If the presetOptions array is not large enough, append the new object
                if presetOptionsCount >= presetOptions.count {
                    presetOptions.append(newOptionsObject)
                } else {
                    // Otherwise, update the existing option object
                    presetOptions[presetOptionsCount].correspondingIndex = newOptionsObject.correspondingIndex
                    presetOptions[presetOptionsCount].name = newOptionsObject.name
                    // Ensure the 'additionalChoices' array has the correct size
                    presetOptions[presetOptionsCount].additionalChoices.append(contentsOf: Array(repeating: .init(""), count: max(newOptionsObject.additionalChoicesSize-presetOptions[presetOptionsCount].additionalChoices.count,0)))
                    presetOptions[presetOptionsCount].additionalChoicesSize = newOptionsObject.additionalChoicesSize
                    // Update the 'additionalChoices' array
                    for j in 0..<newOptionsObject.additionalChoicesSize {
                        presetOptions[presetOptionsCount].additionalChoices[j] = newOptionsObject.additionalChoices[j]
                    }
                }
                // Increment the count of preset options
                presetOptionsCount += 1
            }
        }
        // Notify listeners that the object has changed
        objectWillChange.send()
    }

    // This function recomputes the GPA and triggers a UI update
    func recomputeGPA() {
        computeGPA()
        objectWillChange.send()
    }

    // This function triggers a UI update without changing the model data
    func update() {
        objectWillChange.send()
    }
}
