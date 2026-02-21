import JSON

extension GitHub {
    @frozen public enum RefType: Equatable, Sendable {
        case tag
        case branch
    }
}
extension GitHub.RefType: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .tag:      "tag"
        case .branch:   "branch"
        }
    }
}
extension GitHub.RefType: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "tag":     self = .tag
        case "branch":  self = .branch
        default:        return nil
        }
    }
}
extension GitHub.RefType: JSONStringDecodable, JSONStringEncodable {
}
