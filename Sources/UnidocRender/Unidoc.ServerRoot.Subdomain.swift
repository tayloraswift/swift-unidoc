extension Unidoc.ServerRoot {
    @frozen public enum Subdomain {
        case api
    }
}
extension Unidoc.ServerRoot.Subdomain: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .api:  "api"
        }
    }
}
