// `defaultScoreAndBaseGPAPair` represents the mapping between scores and GPAs in a typical grading system.
// Each pair contains a percentage score ("percentageName"), a corresponding letter grade ("letterName"), and the equivalent GPA ("baseGPA").
let defaultScoreAndBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "0", letterName: "F", baseGPA: 0),
    .init(percentageName:"60", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName:"68", letterName: "C+", baseGPA: 3.0),
    .init(percentageName:"73", letterName: "B-", baseGPA: 3.3),
    .init(percentageName:"78", letterName: "B", baseGPA: 3.6),
    .init(percentageName:"83", letterName: "B+", baseGPA: 3.9),
    .init(percentageName:"88", letterName: "A-", baseGPA: 4.2),
    .init(percentageName:"93", letterName: "A/A+", baseGPA: 4.5),
]

// `ibScoreAndBaseGPAPair` represents the mapping between scores and GPAs in the International Baccalaureate (IB) system.
// The naming for the IB score system differs from the typical grading system, hence the different names used for "percentageName".
let ibScoreAndBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0),
    .init(percentageName: "H4", letterName: "C/C-", baseGPA: 2.6),
    .init(percentageName: "L5", letterName: "C+", baseGPA: 3.0),
    .init(percentageName: "H5", letterName: "B-", baseGPA: 3.3),
    .init(percentageName: "L6", letterName: "B", baseGPA: 3.6),
    .init(percentageName: "H6", letterName: "B+", baseGPA: 3.9),
    .init(percentageName: "L7", letterName: "A-", baseGPA: 4.2),
    .init(percentageName: "H7", letterName: "A/A+", baseGPA: 4.5)
]

// `ibOtherScoreToBaseGPAPair` represents another mapping between scores and GPAs used in the IB system, for ToK and EE.
// Similar to `ibScoreAndBaseGPAPair`, this array uses the specific naming scheme used in the IB grading system.
let ibOtherScoreToBaseGPAPair: [ScoreAndBaseGPAPair] = [
    .init(percentageName: "F", letterName: "F", baseGPA: 0.0),
    .init(percentageName: "D", letterName: "D", baseGPA: 0.0),
    .init(percentageName: "C", letterName: "C", baseGPA: 2.5),
    .init(percentageName: "B", letterName: "B", baseGPA: 4.0),
    .init(percentageName: "A", letterName: "A", baseGPA: 4.5)
]
