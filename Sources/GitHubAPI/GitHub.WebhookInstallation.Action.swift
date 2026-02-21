import JSON

extension GitHub.WebhookInstallation {
    @frozen public enum Action: Equatable, Sendable {
        case created
        case deleted
    }
}
extension GitHub.WebhookInstallation.Action: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .created:  "created"
        case .deleted:  "deleted"
        }
    }
}
extension GitHub.WebhookInstallation.Action: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "created": self = .created
        case "deleted": self = .deleted
        default:        return nil
        }
    }
}
extension GitHub.WebhookInstallation.Action: JSONStringDecodable, JSONStringEncodable {
}
