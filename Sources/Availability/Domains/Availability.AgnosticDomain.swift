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
    typealias Bound = NumericVersion
    public
    typealias Deprecation = Availability.VersionRange
}
