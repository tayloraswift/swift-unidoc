import BSON

extension Unidoc.Census {
    @frozen public enum Interface: Equatable, Hashable, Sendable {
        case unrestricted
        case underscored
        case spi(String?)
    }
}
extension Unidoc.Census.Interface: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool {
        switch (a, b) {
        case (.unrestricted, .unrestricted):    return false
        case (.unrestricted, _):                return true
        case (_, .unrestricted):                return false

        case (.underscored, .underscored):      return false
        case (.underscored, _):                 return true
        case (_, .underscored):                 return false

        case (.spi(nil), .spi(nil)):            return false
        case (.spi(nil), _):                    return true
        case (_, .spi(nil)):                    return false

        case (.spi(let a?), .spi(let b?)):      return a < b
        }
    }
}
extension Unidoc.Census.Interface: RawRepresentable {
    @inlinable public init?(rawValue: String) {
        switch rawValue {
        case "":                self = .unrestricted
        case "__underscored__": self = .underscored
        case "__unknown__":     self = .spi(nil)
        case let name:          self = .spi(name)
        }
    }

    @inlinable public var rawValue: String {
        switch self {
        case .spi(let name?):   name
        case .spi(nil):         "__unknown__"
        case .underscored:      "__underscored__"
        case .unrestricted:     ""
        }
    }
}
extension Unidoc.Census.Interface: BSON.Keyspace {
}
