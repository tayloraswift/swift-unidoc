extension Repository.Dependency
{
    @frozen public
    struct Resolvable:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let requirement:Requirement
        public
        let location:Repository

        @inlinable public
        init(id:PackageIdentifier, requirement:Requirement, location:Repository)
        {
            self.id = id
            self.requirement = requirement
            self.location = location
        }
    }
}
