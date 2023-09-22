import ModuleGraphs
import SemanticVersions
import SHA1
import Unidoc

extension Volume.Vertex
{
    @frozen public
    struct Meta:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        /// The ABI version of the symbol graph this record and associated records were
        /// generated from.
        public
        var abi:MinorVersion
        public
        var dependencies:[Dependency]
        /// Note: this is called `requirements` in the SymbolGraph API. We chose a different
        /// name here to avoid confusion with protocol requirements, which inhabit the same
        /// keyspace as this field.
        public
        var platforms:[PlatformRequirement]
        public
        var revision:SHA1?

        public
        var census:Volume.Census

        @inlinable public
        init(id:Unidoc.Scalar,
            abi:MinorVersion,
            dependencies:[Dependency] = [],
            platforms:[PlatformRequirement] = [],
            revision:SHA1? = nil,
            census:Volume.Census = .init())
        {
            self.id = id

            self.abi = abi
            self.dependencies = dependencies
            self.platforms = platforms
            self.revision = revision
            self.census = census
        }
    }
}