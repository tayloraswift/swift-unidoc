import SymbolGraphs

extension SPM.Manifest {
    @frozen public enum DependencyRequirement: Hashable, Equatable, Sendable {
        /// Due to a SwiftPM quirk, this is not always a SHA-1 hash, it can also point to a tag
        case revision   (String)
        case branch     (String)
        case stable     (SymbolGraphMetadata.DependencyRequirement)
    }
}
extension SPM.Manifest.DependencyRequirement {
    @inlinable public var stable: SymbolGraphMetadata.DependencyRequirement? {
        if  case .stable(let requirement) = self {
            requirement
        } else {
            nil
        }
    }
}
