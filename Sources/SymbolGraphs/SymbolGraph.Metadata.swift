import Repositories
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
        let version:Repository.Reference?
        public
        let format:SemanticVersion

        public
        let requirements:[PlatformRequirement]
        public
        let products:[Product]
        public
        let pins:[Pin]

        public
        init(package:PackageIdentifier,
            version:Repository.Reference?,
            format:SemanticVersion,
            requirements:[PlatformRequirement],
            products:[Product],
            pins:[Pin])
        {
            self.package = package
            self.version = version
            self.format = format
            self.requirements = requirements
            self.products = products
            self.pins = pins
        }
    }
}
