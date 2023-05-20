// `GPAComputePart` represents the result of a GPA computation
struct GPAComputePart {
    let value: Double  // The computed GPA value
    let weight: Double  // The weight assigned to this GPA computation

    // Weighted GPA value is the product of the GPA value and its corresponding weight
    var weightedValue: Double {
        return value * weight
    }
}
