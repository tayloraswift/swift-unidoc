import SemanticVersions

extension Availability
{
    @frozen public
    enum PlatformDomain:String, CaseIterable, Hashable, Sendable
    {
        case iOS
        case macOS
        case macCatalyst
        case tvOS
        case watchOS
        case windows    = "Windows"
        case openBSD    = "OpenBSD"

        case iOSApplicationExtension
        case macOSApplicationExtension
        case macCatalystApplicationExtension
        case tvOSApplicationExtension
        case watchOSApplicationExtension
    }
}
extension Availability.PlatformDomain:AvailabilityDomain
{
    public
    typealias Bound = NumericVersion
    public
    typealias Deprecation = Availability.AnyRange
    public
    typealias Unavailability = Availability.EternalRange
}
