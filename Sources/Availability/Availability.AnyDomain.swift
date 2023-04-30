extension Availability 
{
    // https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/AvailabilityMixin.cpp
    @frozen public 
    enum AnyDomain:Hashable, Equatable
    {
        case agnostic(AgnosticDomain)
        case platform(PlatformDomain)
        case universal
    }
}
extension Availability.AnyDomain:CustomStringConvertible
{
    @inlinable public 
    var description:String 
    {
        switch self 
        {
        case .agnostic(let agnostic):   return agnostic.rawValue
        case .platform(let platform):   return platform.rawValue
        case .universal:                return "*"
        }
    }
}
extension Availability.AnyDomain:LosslessStringConvertible
{
    @inlinable public 
    init?(_ description:String)
    {
        if description == "*"
        {
            self = .universal
        }
        else if let agnostic:Availability.AgnosticDomain = .init(rawValue: description)
        {
            self = .agnostic(agnostic)
        }
        else if let platform:Availability.PlatformDomain = .init(rawValue: description)
        {
            self = .platform(platform)
        }
        else 
        {
            return nil 
        }
    }
}
