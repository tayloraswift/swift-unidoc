import Availability

extension Availability
{
    /// Represents an ``Availability.AnyDomain`` in the BSON ABI. This has a
    /// single-character raw value, for storage efficiency, and is not intended
    /// to be human-readable.
    @frozen public
    struct CodingKey:Equatable, Hashable, Sendable
    {
        public
        let domain:AnyDomain

        @inlinable public
        init(_ domain:AnyDomain)
        {
            self.domain = domain
        }
    }
}
extension Availability.CodingKey:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        switch rawValue
        {
        case "s":   self.init(.agnostic(.swift))
        case "p":   self.init(.agnostic(.swiftPM))
        case "i":   self.init(.platform(.iOS))
        case "m":   self.init(.platform(.macOS))
        case "c":   self.init(.platform(.macCatalyst))
        case "t":   self.init(.platform(.tvOS))
        case "w":   self.init(.platform(.watchOS))
        case "n":   self.init(.platform(.windows))
        case "o":   self.init(.platform(.openBSD))
        case "I":   self.init(.platform(.iOSApplicationExtension))
        case "M":   self.init(.platform(.macOSApplicationExtension))
        case "C":   self.init(.platform(.macCatalystApplicationExtension))
        case "T":   self.init(.platform(.tvOSApplicationExtension))
        case "W":   self.init(.platform(.watchOSApplicationExtension))
        case "u":   self.init(.universal)
        default:    return nil
        }
    }
    @inlinable public
    var rawValue:String
    {
        switch self.domain
        {
        case .agnostic(.swift):                             return "s"
        case .agnostic(.swiftPM):                           return "p"
        case .platform(.iOS):                               return "i"
        case .platform(.macOS):                             return "m"
        case .platform(.macCatalyst):                       return "c"
        case .platform(.tvOS):                              return "t"
        case .platform(.watchOS):                           return "w"
        case .platform(.windows):                           return "n"
        case .platform(.openBSD):                           return "o"
        case .platform(.iOSApplicationExtension):           return "I"
        case .platform(.macOSApplicationExtension):         return "M"
        case .platform(.macCatalystApplicationExtension):   return "C"
        case .platform(.tvOSApplicationExtension):          return "T"
        case .platform(.watchOSApplicationExtension):       return "W"
        case .universal:                                    return "u"
        }
    }
}
