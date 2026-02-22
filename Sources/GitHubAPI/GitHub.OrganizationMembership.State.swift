import JSON

extension GitHub.OrganizationMembership {
    @frozen public enum State: Int32, Sendable {
        case pending = 0
        case active = 1
        case inactive = 2
    }
}
extension GitHub.OrganizationMembership.State: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .pending:  "pending"
        case .active:   "active"
        case .inactive: "inactive"
        }
    }
}
extension GitHub.OrganizationMembership.State: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "pending":     self = .pending
        case "active":      self = .active
        case "inactive":    self = .inactive
        default:            return nil
        }
    }
}
extension GitHub.OrganizationMembership.State: JSONStringEncodable, JSONStringDecodable {
}
