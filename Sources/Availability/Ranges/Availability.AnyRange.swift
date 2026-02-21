import SemanticVersions

extension Availability {
    @frozen public enum AnyRange: Equatable, Hashable, Sendable {
        case unconditionally
        case since(NumericVersion?)
    }
}
extension Availability.AnyRange {
    @inlinable public init(_ other: Availability.VersionRange) {
        switch other {
        case .since(let version): self = .since(version)
        }
    }
}
