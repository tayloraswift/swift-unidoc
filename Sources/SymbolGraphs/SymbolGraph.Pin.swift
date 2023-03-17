extension SymbolGraph
{
    @frozen public
    struct Pin:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let reference:GitReference
        public
        let revision:GitRevision
        public
        let range:Range<SemanticVersion>?

        @inlinable public
        init(id:PackageIdentifier,
            reference:GitReference,
            revision:GitRevision,
            range:Range<SemanticVersion>?)
        {
            self.id = id
            self.reference = reference
            self.revision = revision
            self.range = range
        }
    }
}
