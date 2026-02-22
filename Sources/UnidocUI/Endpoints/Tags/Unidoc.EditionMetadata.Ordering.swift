import SemanticVersions

extension Unidoc.EditionMetadata {
    enum Ordering: Comparable {
        case versionless(String)
        case versioned(PatchVersion)
    }
}
