extension Subject {
    /// Convenience initializer to quickly create an IB subject with a specific name.
    /// The method uses specific settings relevant for IB EE and ToK.
    static func defaultIbOther(name: String) -> Subject {
        return .init(name: .init(name), alternateNames: nil, levels: [.init(name: "IB", weight: 0.5, offset: 0)], scoreAndBaseGPAPairs: ibOtherScoreToBaseGPAPair)
    }
    
    /// Convenience initializer to quickly create an IB subject with a specific name.
    /// The method uses specific settings relevant for IB subjects.
    static func defaultIb(name: String, alternateNames: [SizeDependentString]? = nil) -> Subject {
        return defaultIb(name: SizeDependentString.init(name), alternateNames: alternateNames)
    }
    
    /// Convenience initializer to quickly create an IB subject with a specific name.
    /// The method uses specific settings relevant for IB subjects.
    static func defaultIb(name: SizeDependentString, alternateNames: [SizeDependentString]? = nil) -> Subject {
        return .init(name: name, alternateNames: alternateNames, levels: [.init(name: "IB", weight: 1.0, offset: 0)], scoreAndBaseGPAPairs: ibScoreAndBaseGPAPair)
    }
    
    /// Convenience initializer to quickly create an English subject with a specific weight.
    /// The method uses specific settings relevant for English subjects, with an optional AP level.
    static func defaultEnglish(weight: Double, hasAP: Bool) -> Subject {
        var levels: [Level] = []
        levels.append(.init(name: "S", weight: weight, offset: -0.5))
        levels.append(.init(name: "S+", weight: weight, offset: -0.4))
        levels.append(.init(name: "H", weight: weight, offset: -0.2))
        levels.append(.init(name: "H+", weight: weight, offset: -0.1))
        if hasAP {
            levels.append(.init(name: "AP", weight: weight, offset: 0))
        }
        return .init(name: .init("English"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
    
    /// Convenience initializer to quickly create a Chinese subject with a specific weight.
    /// The method uses specific settings relevant for Chinese subjects, with an optional H+ level.
    static func defaultChinese(weight: Double, hasHP: Bool, middleLevelName: String, isMiddleSchoolChinese: Bool) -> Subject {
        // Middle school Chinese has GPA offsets 0.1 higher
        let levelsOffsetOffset = isMiddleSchoolChinese ? 0.1 : 0
        
        var levels: [Level] = []
        levels.append(.init(name: "1-2", weight: weight, offset: -0.5 + levelsOffsetOffset))
        levels.append(.init(name: "3-4", weight: weight, offset: -0.4 + levelsOffsetOffset))
        levels.append(.init(name: middleLevelName, weight: weight, offset: -0.3 + levelsOffsetOffset))
        levels.append(.init(name: "H", weight: weight, offset: -0.2 + levelsOffsetOffset))
        if hasHP {
            levels.append(.init(name: "H+", weight: weight, offset: -0.1 + levelsOffsetOffset))
        }
        
        return .init(name: .init("Chinese"), alternateNames: nil, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
    
    /// Convenience initializer to quickly create other subjects with a specific weight.
    /// The method uses specific settings relevant for other subjects, with optional S+, H, A-level, AP levels.
    static func defaultOther(name: String, weight: Double, alternateNames: [SizeDependentString]? = nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double? = nil, apCustomWeight: Double? = nil) -> Subject {
        return defaultOther(name: .init(name), weight: weight, alternateNames: alternateNames, hasSP: hasSP, hasH: hasH, hasAL: hasAL, hasAP: hasAP, alCustomWeight: alCustomWeight, apCustomWeight: apCustomWeight)
    }
    
    /// Convenience initializer to quickly create other subjects with a specific weight.
    /// The method uses specific settings relevant for other subjects, with optional S+, H, A-level, AP levels.
    static func defaultOther(name: SizeDependentString, weight: Double, alternateNames: [SizeDependentString]? = nil, hasSP: Bool, hasH: Bool, hasAL: Bool, hasAP: Bool, alCustomWeight: Double? = nil, apCustomWeight: Double? = nil) -> Subject {
        var levels: [Level] = []
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
        return .init(name: name, alternateNames: alternateNames, levels: levels, scoreAndBaseGPAPairs: defaultScoreAndBaseGPAPair)
    }
}
