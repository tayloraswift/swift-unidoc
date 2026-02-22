extension Unidoc {
    @frozen @usableFromInline enum LoginFlow {
        /// Single sign-on.
        case sso
        /// Synchronize permissions with GitHub.
        case sync
    }
}
extension Unidoc.LoginFlow: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .sso:  "sso"
        case .sync: "sync"
        }
    }
}
extension Unidoc.LoginFlow: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
        case "sso":     self = .sso
        case "sync":    self = .sync
        default:        return nil
        }
    }
}
