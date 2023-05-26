import ModuleGraphs

extension TargetNode
{
    @frozen public
    struct Dependencies:Equatable, Sendable
    {
        public
        var products:[Dependency<ProductIdentifier>]
        public
        var targets:[Dependency<String>]

        @inlinable public
        init(
            products:[Dependency<ProductIdentifier>] = [],
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
    func products(on platform:PlatformIdentifier)
        -> TargetNode.DependencyView<ProductIdentifier>
    {
        .init(platform: platform, base: self.products)
    }
    @inlinable public
    func targets(on platform:PlatformIdentifier)
        -> TargetNode.DependencyView<String>
    {
        .init(platform: platform, base: self.targets)
    }
}
