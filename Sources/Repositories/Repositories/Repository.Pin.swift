extension Repository
{
    @frozen public 
    struct Pin:Identifiable, Equatable, Sendable 
    {
        public 
        let id:PackageIdentifier
        public
        let reference:Reference
        public 
        let revision:Revision
        public
        let location:Repository

        @inlinable public 
        init(id:PackageIdentifier, reference:Reference, revision:Revision, location:Repository)
        {
            self.id = id 
            self.reference = reference
            self.revision = revision 
            self.location = location 
        }
    }
}
