import HTTP
import JSON
import MongoDB
import UnidocDB
import UnidocRender

extension Unidoc {
    public protocol MachineOperation: RestrictedOperation {
    }
}
extension Unidoc.MachineOperation {
    /// The machine endpoints are restricted to administratrices and machine users.
    @inlinable public func admit(user: Unidoc.UserRights) -> Bool {
        switch user.level {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        case .guest:            false
        }
    }
}
