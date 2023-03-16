extension PackageDependency
{
    @frozen public
    struct Filesystem:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:PackageRoot

        @inlinable public
        init(id:PackageIdentifier, location:PackageRoot)
        {
            self.id = id
            self.location = location
        }
    }
}
