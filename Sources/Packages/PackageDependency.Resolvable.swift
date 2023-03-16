extension PackageDependency
{
    @frozen public
    struct Resolvable:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let requirement:PackageRequirement
        public
        let location:PackageRepository

        @inlinable public
        init(id:PackageIdentifier, requirement:PackageRequirement, location:PackageRepository)
        {
            self.id = id
            self.requirement = requirement
            self.location = location
        }
    }
}
