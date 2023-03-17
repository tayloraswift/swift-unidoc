extension TargetDependency
{
    @frozen public
    struct Target:Identifiable, Equatable, Sendable
    {
        public
        let id:TargetIdentifier
        public
        let platforms:[PlatformIdentifier]

        @inlinable public
        init(id:TargetIdentifier, platforms:[PlatformIdentifier] = [])
        {
            self.id = id
            self.platforms = platforms
        }
    }
}
