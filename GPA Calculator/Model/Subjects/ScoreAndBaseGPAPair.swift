// `ScoreAndBaseGPAPair` pairs a `Score` with a base GPA value
struct ScoreAndBaseGPAPair {
    let score: Score  // The score object
    let baseGPA: Double  // The base GPA corresponding to the score
    
    init(percentageName: String, letterName: String, baseGPA: Double) {
        self.score = .init(percentageName: percentageName, letterName: letterName)
        self.baseGPA = baseGPA
    }
}
