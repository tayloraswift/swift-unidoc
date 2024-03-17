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
        public
        var nominal:[Dependency<String>]

        @inlinable public
        init(
            products:[Dependency<Symbol.Product>] = [],
            targets:[Dependency<String>] = [],
            nominal:[Dependency<String>] = [])
        {
            self.products = products
            self.targets = targets
            self.nominal = nominal
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
    @inlinable public
    func nominal(
        on platform:SymbolGraphMetadata.Platform) -> TargetNode.DependencyView<String>
    {
        .init(platform: platform, base: self.nominal)
    }
}
