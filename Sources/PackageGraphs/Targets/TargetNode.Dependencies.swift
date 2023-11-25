import SymbolGraphs
import Symbols

extension TargetNode
{
    @frozen public
    struct Dependencies:Equatable, Sendable
    {
        public
        var products:[Dependency<Symbol.Product>]
        public
        var targets:[Dependency<String>]

        @inlinable public
        init(
            products:[Dependency<Symbol.Product>] = [],
            targets:[Dependency<String>] = [])
        {
            self.products = products
            self.targets = targets
        }
    }
}
extension TargetNode.Dependencies
{
    @inlinable public
    func products(
        on platform:SymbolGraphMetadata.Platform) -> TargetNode.DependencyView<Symbol.Product>
    {
        .init(platform: platform, base: self.products)
    }
    @inlinable public
    func targets(
        on platform:SymbolGraphMetadata.Platform) -> TargetNode.DependencyView<String>
    {
        .init(platform: platform, base: self.targets)
    }
}
