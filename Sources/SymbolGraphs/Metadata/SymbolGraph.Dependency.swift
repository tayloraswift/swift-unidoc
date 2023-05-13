import PackageGraphs
import SemanticVersions

extension SymbolGraph
{
    @frozen public
    struct Dependency:Equatable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let requirement:Range<SemanticVersion>?
        public
        let revision:Repository.Revision
        public
        let ref:Repository.Ref

        @inlinable public
        init(package:PackageIdentifier,
            requirement:Range<SemanticVersion>?,
            revision:Repository.Revision,
            ref:Repository.Ref)
        {
            self.package = package
            self.requirement = requirement
            self.revision = revision
            self.ref = ref
        }
    }
}
