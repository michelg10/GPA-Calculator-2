//
//  AppSingleton.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/2.
//

import Foundation

class AppSingleton:ObservableObject {
    @Published var currentGPA="0.000"
    var allPresets: [Course]
    var currentPreset: Course
    var userInput: [UserCourseInput]
    var nameMode = NameMode.percentage
    init() {
        allPresets = getPresets()
        currentPreset = allPresets[2]
        userInput = Array(repeating: .init(levelIndex: 0, scoreIndex: 0), count: currentPreset.getSubjects().count)
    }
    
}
