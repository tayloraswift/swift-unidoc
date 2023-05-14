import PackageGraphs

extension PackageManifest.Target
{
    struct DependencyIterator<Element> where Element:Hashable
    {
        private
        let platform:PlatformIdentifier
        private
        var base:IndexingIterator<[Dependency<Element>]>

        init(platform:PlatformIdentifier, base:IndexingIterator<[Dependency<Element>]>)
        {
            self.platform = platform
            self.base = base
        }
    }
}
extension PackageManifest.Target.DependencyIterator:IteratorProtocol
{
    mutating
    func next() -> Element?
    {
        while let dependency:PackageManifest.Target.Dependency<Element> = self.base.next()
        {
            if  dependency.platforms.isEmpty || dependency.platforms.contains(self.platform)
            {
                return dependency.id
            }
        }
        return nil
    }
}
