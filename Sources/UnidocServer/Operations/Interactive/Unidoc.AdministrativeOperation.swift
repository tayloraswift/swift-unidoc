import UnidocDB

extension Unidoc {
    public protocol AdministrativeOperation: RestrictedOperation {
    }
}

extension Unidoc.AdministrativeOperation {
    @inlinable public func admit(user: Unidoc.UserRights) -> Bool {
        switch user.level {
        case .administratrix:   true
        case .machine:          false
        case .human:            false
        case .guest:            false
        }
    }
}
