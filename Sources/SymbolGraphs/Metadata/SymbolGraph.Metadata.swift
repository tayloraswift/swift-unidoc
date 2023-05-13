import PackageGraphs
import SemanticVersions

extension SymbolGraph
{
    public
    struct Metadata:Equatable, Sendable
    {
        /// The package this symbolgraph is for.
        public
        let package:PackageIdentifier
        public
        let triple:Triple
        public
        let format:SemanticVersion

        public
        let revision:Repository.Revision?
        public
        let ref:Repository.Ref?

        public
        let requirements:[PlatformRequirement]
        public
        let dependencies:[Dependency]
        public
        let products:[ProductNode]

        public
        init(package:PackageIdentifier, triple:Triple,
            format:SemanticVersion = .v(0, 1, 0),
            revision:Repository.Revision? = nil,
            ref:Repository.Ref? = nil,
            requirements:[PlatformRequirement] = [],
            dependencies:[Dependency] = [],
            products:[ProductNode] = [])
        {
            self.package = package
            self.triple = triple
            self.format = format

            self.revision = revision
            self.ref = ref

            self.requirements = requirements
            self.dependencies = dependencies
            self.products = products
        }
    }
}
extension SymbolGraph.Metadata
{
    public static
    func swift(triple:Triple, ref:Repository.Ref? = nil) -> Self
    {
        .init(package: .swift, triple: triple, ref: ref)
    }
}
