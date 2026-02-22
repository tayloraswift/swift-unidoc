extension Unidoc.EditionMetadata {
    var ordering: Ordering {
        self.semver.map { .versioned($0) } ?? .versionless(self.name)
    }
}
