extension Repository.Dependency
{
    @frozen public
    struct Filesystem:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:Repository.Root

        @inlinable public
        init(id:PackageIdentifier, location:Repository.Root)
        {
            self.id = id
            self.location = location
        }
    }
}
