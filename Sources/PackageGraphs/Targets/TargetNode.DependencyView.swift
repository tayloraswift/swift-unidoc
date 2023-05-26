import ModuleGraphs

extension TargetNode
{
    @frozen public
    struct DependencyView<Element> where Element:Hashable
    {
        @usableFromInline internal
        let platform:PlatformIdentifier
        @usableFromInline internal
        let base:[Dependency<Element>]

        @inlinable internal
        init(platform:PlatformIdentifier, base:[Dependency<Element>])
        {
            self.platform = platform
            self.base = base
        }
    }
}
extension TargetNode.DependencyView:Sequence
{
    @inlinable public
    func makeIterator() -> TargetNode.DependencyIterator<Element>
    {
        .init(platform: self.platform, base: self.base.makeIterator())
    }
}
