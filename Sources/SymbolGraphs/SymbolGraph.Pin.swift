import Repositories
import SemanticVersions

extension SymbolGraph
{
    @frozen public
    struct Pin:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let reference:Repository.Reference
        public
        let revision:Repository.Revision
        public
        let range:Range<SemanticVersion>?

        @inlinable public
        init(id:PackageIdentifier,
            reference:Repository.Reference,
            revision:Repository.Revision,
            range:Range<SemanticVersion>?)
        {
            self.id = id
            self.reference = reference
            self.revision = revision
            self.range = range
        }
    }
}
