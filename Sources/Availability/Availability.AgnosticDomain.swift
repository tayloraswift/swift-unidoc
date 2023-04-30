import SemanticVersions

extension Availability
{
    @frozen public 
    enum AgnosticDomain:String, CaseIterable, Hashable, Equatable, Sendable 
    {
        case swift = "Swift"
        case swiftPM = "SwiftPM"
    }
}
extension Availability.AgnosticDomain:AvailabilityDomain
{
    public
    typealias Bound = SemanticVersionMask
    public
    typealias Deprecation = SemanticVersionMask
}
