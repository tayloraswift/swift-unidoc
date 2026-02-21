@frozen public enum MediaEncoding: Equatable, Hashable, Sendable {
    case gzip
    case br
}
extension MediaEncoding: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .gzip: "gzip"
        case .br:   "br"
        }
    }
}
extension MediaEncoding: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "gzip": self = .gzip
        case "br":   self = .br
        default:     return nil
        }
    }
}
