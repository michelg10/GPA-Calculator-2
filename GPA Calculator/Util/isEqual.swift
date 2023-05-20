/// Checks if two `Double` values are approximately equal within a very small tolerance.
/// This function is useful for floating point comparisons where exact equality isn't practical.
///
/// - Parameters:
///   - a: The first `Double` value.
///   - b: The second `Double` value.
/// - Returns: `True` if `a` and `b` are approximately equal within the tolerance of `0.000001`. Otherwise, `false`.
func isEqual(_ a: Double, _ b: Double) -> Bool {
    return abs(a - b) < 0.000001
}
