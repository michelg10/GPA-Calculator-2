/// `NameMode` is an enumeration representing different modes of score representation,
/// namely by `letter` (A, B, C, D, E, F) or by `percentage` (93, 83, etc.).
enum NameMode: String, CaseIterable, Identifiable {
    case percentage // Represents scores as percentages.
    case letter    // Represents scores as letters.

    /// The `id` property provides a unique identifier for each case in the enumeration,
    /// required by the `Identifiable` protocol. It is based on the raw value of each case.
    var id: String { self.rawValue }
}
