extension SymbolAvailability
{
    @frozen public 
    enum Agnostic:String, CaseIterable, Hashable, Equatable, Sendable 
    {
        case swift = "Swift"
        case swiftPM = "SwiftPM"
    }
}
