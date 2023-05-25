import ModuleGraphs

extension PackageManifest.Target
{
    @frozen public
    struct Dependency<ID>:Identifiable, Equatable, Hashable where ID:Hashable
    {
        public
        let id:ID
        public
        let platforms:[PlatformIdentifier]

        @inlinable public
        init(id:ID, platforms:[PlatformIdentifier] = [])
        {
            self.id = id
            self.platforms = platforms
        }
    }
}
extension PackageManifest.Target.Dependency:Sendable where ID:Sendable
{
}
