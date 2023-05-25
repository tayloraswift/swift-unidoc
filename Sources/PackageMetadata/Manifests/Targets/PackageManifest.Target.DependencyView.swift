import ModuleGraphs

extension PackageManifest.Target
{
    struct DependencyView<Element> where Element:Hashable
    {
        private
        let platform:PlatformIdentifier
        private
        let base:[Dependency<Element>]

        init(platform:PlatformIdentifier, base:[Dependency<Element>])
        {
            self.platform = platform
            self.base = base
        }
    }
}
extension PackageManifest.Target.DependencyView:Sequence
{
    func makeIterator() -> PackageManifest.Target.DependencyIterator<Element>
    {
        .init(platform: self.platform, base: self.base.makeIterator())
    }
}
