extension Availability 
{
    // https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/AvailabilityMixin.cpp
    @frozen public 
    enum DomainIdentifier:RawRepresentable, Hashable, Equatable
    {
        case all
        case agnostic(Agnostic)
        case platform(Platform)
        
        @inlinable public 
        init?(rawValue:String)
        {
            if rawValue == "*"
            {
                self = .all
            }
            else if let agnostic:Agnostic = .init(rawValue: rawValue)
            {
                self = .agnostic(agnostic)
            }
            else if let platform:Platform = .init(rawValue: rawValue)
            {
                self = .platform(platform)
            }
            else 
            {
                return nil 
            }
        }
        @inlinable public 
        var rawValue:String 
        {
            switch self 
            {
            case .all:                      return "*"
            case .agnostic(let agnostic):   return agnostic.rawValue
            case .platform(let platform):   return platform.rawValue
            }
        }
    }
}
