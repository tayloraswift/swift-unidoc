extension Unidoc {
    @frozen public enum Bias: Equatable {
        case culture(Unidoc.Scalar)
        case neutral
        case package
    }
}
extension Unidoc.Bias {
    @inlinable public var edition: Unidoc.Edition? {
        switch self {
        case .culture(let culture): culture.edition
        case .neutral:              nil
        case .package:              nil
        }
    }
}
