import SemanticVersions

extension Availability
{
    @frozen public
    enum PlatformDomain:String, CaseIterable, Equatable, Hashable, Sendable
    {
        case iOS
        case macOS
        case macCatalyst
        case openBSD    = "OpenBSD"
        case tvOS
        case watchOS
        case windows    = "Windows"

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
extension Availability.PlatformDomain:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .iOS:                              return "iOS"
        case .macOS:                            return "macOS"
        case .macCatalyst:                      return "Mac Catalyst"
        case .openBSD:                          return "OpenBSD"
        case .tvOS:                             return "tvOS"
        case .watchOS:                          return "watchOS"
        case .windows:                          return "Windows"
        case .iOSApplicationExtension:          return "iOS App Extension"
        case .macOSApplicationExtension:        return "macOS App Extension"
        case .macCatalystApplicationExtension:  return "Mac Catalyst App Extension"
        case .tvOSApplicationExtension:         return "tvOS App Extension"
        case .watchOSApplicationExtension:      return "watchOS App Extension"
        }
    }
}
