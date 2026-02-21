extension Unidoc.VolumeMetadata {
    @frozen public enum DependencyPin: Equatable, Sendable {
        case linked(Unidoc.Edition)
        case pinned(Unidoc.Edition)
    }
}
extension Unidoc.VolumeMetadata.DependencyPin {
    @inlinable public var edition: Unidoc.Edition {
        switch self {
        case .linked(let edition):  edition
        case .pinned(let edition):  edition
        }
    }

    @inlinable public var linked: Unidoc.Edition? {
        switch self {
        case .linked(let edition):  edition
        case .pinned:               nil
        }
    }
}
