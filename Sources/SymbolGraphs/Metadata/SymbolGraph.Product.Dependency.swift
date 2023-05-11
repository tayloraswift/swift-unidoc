import Repositories

extension SymbolGraph.Product
{
    @frozen public
    struct Dependency:Equatable, Hashable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let products:[ProductIdentifier]

        @inlinable public
        init(id:PackageIdentifier, products:[ProductIdentifier])
        {
            self.id = id
            self.products = products
        }
    }
}
