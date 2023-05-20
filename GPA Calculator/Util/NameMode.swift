enum NameMode: String, CaseIterable, Identifiable {
    case percentage
    case letter
    
    var id: String { self.rawValue }
}
