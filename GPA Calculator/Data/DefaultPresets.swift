import Foundation

var presets: [Preset] = {
    let g6 = Preset.init(id: "stockshsidgrade6", name: "Grade 6", subjectComputeGroups: [
        Subject.defaultEnglish(weight: 6.5, hasAP: false),
        Subject.defaultOther(name: "Math", weight: 6.5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultChinese(weight: 5, hasHP: false, middleLevelName: "S", isMiddleSchoolChinese: true),
        Subject.defaultOther(name: "Science", weight: 2.5, hasSP: true, hasH: false, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "History", weight: 2.5, hasSP: true, hasH: false, hasAL: false, hasAP: false)
    ])
    
    let g7 = Preset.init(id: "stockshsidgrade7", name: "Grade 7", subjectComputeGroups: [
        Subject.defaultEnglish(weight: 6, hasAP: false),
        Subject.defaultOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "History", weight: 5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultChinese(weight: 5, hasHP: false, middleLevelName: "S", isMiddleSchoolChinese: true),
        Subject.defaultOther(name: "Science", weight: 3, hasSP: true, hasH: false, hasAL: false, hasAP: false),
    ])
    
    let g8 = Preset.init(id: "stockshsidgrade8", name: "Grade 8", subjectComputeGroups: [
        Subject.defaultEnglish(weight: 6, hasAP: false),
        Subject.defaultOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "Geography", weight: 5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultChinese(weight: 5, hasHP: false, middleLevelName: "S/5-7", isMiddleSchoolChinese: true),
        Subject.defaultOther(name: "Biology", weight: 3, hasSP: false, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "Physics", weight: 2.5, hasSP: false, hasH: true, hasAL: false, hasAP: false)
    ])
    
    let g9 = Preset.init(id: "stockshsidgrade9", name: "Grade 9", subjectComputeGroups: [
        Subject.defaultEnglish(weight: 6.5, hasAP: false),
        Subject.defaultOther(name: "Math", weight: 6, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "History", weight: 4, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "Chemistry", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultChinese(weight: 3, hasHP: false, middleLevelName: "S/5-7", isMiddleSchoolChinese: false),
        Subject.defaultOther(name: "Elective", weight: 3, alternateNames: [.init("Biology"), .init("Geography"), .init("ITCS")], hasSP: false, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "Physics", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false)
    ])
    
    let g10ElectivesChoice:[SizeDependentString] = [.init("Biology"), .init("Chi Lit", "Chinese Literature"), .init("Economics"), .init("Geography"), .init("ITCS"), .init("Music"), .init("VA", "Visual Arts")]
    let g10 = Preset.init(id: "stockshsidgrade10", name: "Grade 10", subjectComputeGroups: [
        Subject.defaultOther(name: "Math", weight: 5.5, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultEnglish(weight: 5.5, hasAP: true),
        Subject.defaultOther(name: "History", weight: 4, hasSP: true, hasH: true, hasAL: false, hasAP: true, apCustomWeight: 5),
        Subject.defaultOther(name: "Elective 1", weight: 3, alternateNames: g10ElectivesChoice, hasSP: false, hasH: true, hasAL: false, hasAP: true, apCustomWeight: 4),
        Subject.defaultOther(name: "Elective 2", weight: 3, alternateNames: g10ElectivesChoice, hasSP: false, hasH: true, hasAL: false, hasAP: true, apCustomWeight: 4),
        Subject.defaultChinese(weight: 3, hasHP: true, middleLevelName: "S/AP/5-7", isMiddleSchoolChinese: false),
        Subject.defaultOther(name: "Chemistry", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false),
        Subject.defaultOther(name: "Physics", weight: 3, hasSP: true, hasH: true, hasAL: false, hasAP: false)
    ])
    
    let g11math=Subject.defaultOther(name: "Math", weight: 6, hasSP: false, hasH: true, hasAL: true, hasAP: true)
    let g11english=Subject.defaultEnglish(weight: 6, hasAP: true)
    let module2Options:[SizeDependentString] = [
        .init("Biology"),
        .init("Chemistry"),
        .init("Physics"),
    ]
    let module3Options:[SizeDependentString] = [
        .init("Accounting"),
        .init("Business"),
        .init("Chi History", "Chinese History"),
        .init("Economics"),
        .init("Human Geo", "Human Geography"),
        .init("ITCS"),
        .init("Psych", "Psychology"),
        .init("Studio Art"),
        .init("Tour Geo", "Tourism Geography"),
        .init("US History"),
        .init("US Overv", "US Overview"),
        .init("West Civ", "Western Civilization"),
        .init("World H", "World History"),
    ]
    let module4Options:[SizeDependentString] = [
        .init("Business"),
        .init("Computer", "Computer Skills"),
        .init("E&E", "Energy & Environment)"),
        .init("Global Pers", "Global Perspect8ives"),
        .init("Writing", "Creative Writing"),
    ]
    let module5Options:[SizeDependentString] = [
        .init("Arts"),
        .init("Chemistry"),
        .init("Economics"),
        .init("French"),
        .init("Env. Sci", "Environmental Science"),
        .init("Int. English", "Intensive English"),
        .init("Japanese"),
        .init("Singing"),
    ]
    
    var module45Options=module4Options
    module45Options.append(contentsOf: module5Options)
    let g11m2=Subject.defaultOther(name: "Module 2", weight: 6, alternateNames: module2Options, hasSP: true, hasH: true, hasAL: true, hasAP: true)
    let g11m3=Subject.defaultOther(name: "Module 3", weight: 4.5, alternateNames: module3Options, hasSP: true, hasH: true, hasAL: true, hasAP: true, alCustomWeight: 6)
    let g11chinese=Subject.defaultChinese(weight: 3, hasHP: true, middleLevelName: "S/5-7", isMiddleSchoolChinese: false)
    let g11m45=Subject.defaultOther(name: "Module 4/5", weight: 3, alternateNames: module45Options, hasSP: true, hasH: true, hasAL: true, hasAP: true, alCustomWeight: 6, apCustomWeight: 4.5)
    let g11m4=Subject.defaultOther(name: "Module 4", weight: 3, alternateNames: module4Options, hasSP: true, hasH: true, hasAL: false, hasAP: false)
    let g11m5=Subject.defaultOther(name: "Module 5", weight: 3, alternateNames: module5Options, hasSP: true, hasH: true, hasAL: true, hasAP: true, alCustomWeight: 6.0, apCustomWeight: 4.5)
    
    let g11_2m2_1m3 = Preset.init(id: "stockshsidgrade11-2m2-1m3", name: "Grade 11", subtitle: "2x M2s, 1x M3", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m2,
        g11m3,
        g11chinese
    ])
    
    let g11_1m2_1m3_1m45 = Preset.init(id: "stockshsidgrade11-1m2-1m3-1m45", name: "Grade 11", subtitle: "1x M2, M3, M4/5", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m3,
        g11m45,
        g11chinese
    ])
    
    let g11_1m2_1m3_1m4_1m5 = Preset.init(id: "stockshsidgrade11-1m2-1m3-1m4-1m5", name: "Grade 11", subtitle: "1x M2, M3, M4, M5", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m3,
        MaxSubjectGroup(subjects: [
            g11m4,
            g11m5
        ]),
        g11chinese
    ])
    
    let g12_2m2_1m3 = Preset.init(id: "stockshsidgrade12-2m2-1m3", name: "Grade 12", subtitle: "2x M2s, 1x M3", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m2,
        g11m3,
        g11chinese
    ])
    
    let g12_1m2_1m3_1m45 = Preset.init(id: "stockshsidgrade12-1m2-1m3-1m45", name: "Grade 12", subtitle: "1x M2, M3, M4/5", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m3,
        g11m45,
        g11chinese
    ])
    
    let g12_1m2_1m3_1m4_1m5 = Preset.init(id: "stockshsidgrade12-1m2-1m3-1m4-1m5", name: "Grade 12", subtitle: "1x M2, M3, M4, M5", subjectComputeGroups: [
        g11math,
        g11english,
        g11m2,
        g11m3,
        MaxSubjectGroup(subjects: [
            g11m4,
            g11m5
        ]),
        g11chinese
    ])
    
    let ibElectives: [SizeDependentString] = [.init("Biology"), .init("Chemistry"), .init("Economics"), .init("ESS", "ESS"), .init("History"), .init("ITCS"), .init("Music"), .init("Physics"), .init("Psych", "Psychology"), .init("VA", "Visual Arts")]
    let g11ib = Preset.init(id: "stockshsidgrade11-ib", name: "Grade 11", subtitle: "IB (No EE)", useSmallLevelDisplay: true, subjectComputeGroups: [
        Subject.defaultIb(name: "Math"),
        Subject.defaultIb(name: "English"),
        Subject.defaultIb(name: "Chinese"),
        Subject.defaultIb(name: "Elective 1", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 2", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 3", alternateNames: ibElectives),
        Subject.defaultIbOther(name: "ToK")
    ])
    
    let g11ibEe = Preset.init(id: "stockshsidgrade11-ibee", name: "Grade 11", subtitle: "IB (With EE)", useSmallLevelDisplay: true, subjectComputeGroups: [
        Subject.defaultIb(name: "Math"),
        Subject.defaultIb(name: "English"),
        Subject.defaultIb(name: "Chinese"),
        Subject.defaultIb(name: "Elective 1", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 2", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 3", alternateNames: ibElectives),
        DoubleSubjectGroup(baseGPAMatrix: [
            [0.0,0.0,0.0,0.0,0.0],
            [0.0,0.0,0.0,2.5,4.0],
            [0.0,0.0,2.5,2.5,4.0],
            [0.0,2.5,2.5,4.0,4.5],
            [0.0,4.0,4.0,4.5,4.5]
        ], subjects: [
            Subject.defaultIbOther(name: "ToK"),
            Subject.defaultIbOther(name: "EE")
        ])
    ])
    
    let g12ibEe = Preset.init(id: "stockshsidgrade12-ibee", name: "Grade 12", subtitle: "IB", useSmallLevelDisplay: true, subjectComputeGroups: [
        Subject.defaultIb(name: "Math"),
        Subject.defaultIb(name: "English"),
        Subject.defaultIb(name: "Chinese"),
        Subject.defaultIb(name: "Elective 1", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 2", alternateNames: ibElectives),
        Subject.defaultIb(name: "Elective 3", alternateNames: ibElectives),
        DoubleSubjectGroup(baseGPAMatrix: [
            [0.0,0.0,0.0,0.0,0.0],
            [0.0,0.0,0.0,2.5,4.0],
            [0.0,0.0,2.5,2.5,4.0],
            [0.0,2.5,2.5,4.0,4.5],
            [0.0,4.0,4.0,4.5,4.5]
        ], subjects: [
            Subject.defaultIbOther(name: "ToK"),
            Subject.defaultIbOther(name: "EE")
        ])
    ])
    
    return [g6, g7, g8, g9, g10, g11_2m2_1m3, g11_1m2_1m3_1m45, g11_1m2_1m3_1m4_1m5, g11ib, g11ibEe, g12_2m2_1m3, g12_1m2_1m3_1m45, g12_1m2_1m3_1m4_1m5, g12ibEe]
}()
