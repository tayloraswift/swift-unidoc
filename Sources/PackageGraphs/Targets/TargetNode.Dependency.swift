import ModuleGraphs

extension TargetNode
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
extension TargetNode.Dependency:Sendable where ID:Sendable
{
}
