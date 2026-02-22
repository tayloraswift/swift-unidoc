import Availability
import BSON

extension Availability {
    /// Represents an ``Availability.AnyDomain`` in the BSON ABI. This has a
    /// single-character raw value, for storage efficiency, and is not intended
    /// to be human-readable.
    @frozen public struct CodingKey: BSON.Keyspace {
        public let domain: AnyDomain

        @inlinable public init(_ domain: AnyDomain) {
            self.domain = domain
        }
    }
}
extension Availability.CodingKey: RawRepresentable {
    @inlinable public init?(rawValue: String) {
        switch rawValue {
        case "s":   self.init(.agnostic(.swift))
        case "p":   self.init(.agnostic(.swiftPM))
        case "b":   self.init(.platform(.bridgeOS))
        case "i":   self.init(.platform(.iOS))
        case "m":   self.init(.platform(.macOS))
        case "c":   self.init(.platform(.macCatalyst))
        case "t":   self.init(.platform(.tvOS))
        case "v":   self.init(.platform(.visionOS))
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
    @inlinable public var rawValue: String {
        switch self.domain {
        case .agnostic(.swift):                             "s"
        case .agnostic(.swiftPM):                           "p"
        case .platform(.bridgeOS):                          "b"
        case .platform(.iOS):                               "i"
        case .platform(.macOS):                             "m"
        case .platform(.macCatalyst):                       "c"
        case .platform(.tvOS):                              "t"
        case .platform(.visionOS):                          "v"
        case .platform(.watchOS):                           "w"
        case .platform(.windows):                           "n"
        case .platform(.openBSD):                           "o"
        case .platform(.iOSApplicationExtension):           "I"
        case .platform(.macOSApplicationExtension):         "M"
        case .platform(.macCatalystApplicationExtension):   "C"
        case .platform(.tvOSApplicationExtension):          "T"
        case .platform(.watchOSApplicationExtension):       "W"
        case .universal:                                    "u"
        }
    }
}
