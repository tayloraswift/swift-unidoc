import JSON

extension GitHub.OrganizationMembership {
    @frozen public enum Role: Int32, Sendable {
        case member = 0
        case admin = 1
        case billingManager = 2

        /// This case exists in the wild but is not documented in the GitHub API reference.
        case unaffiliated = 256
    }
}
extension GitHub.OrganizationMembership.Role: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .member:           "member"
        case .admin:            "admin"
        case .billingManager:   "billing_manager"
        case .unaffiliated:     "unaffiliated"
        }
    }
}
extension GitHub.OrganizationMembership.Role: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "member":          self = .member
        case "admin":           self = .admin
        case "billing_manager": self = .billingManager
        case "unaffiliated":    self = .unaffiliated
        default:                return nil
        }
    }
}
extension GitHub.OrganizationMembership.Role: JSONStringEncodable, JSONStringDecodable {
}
