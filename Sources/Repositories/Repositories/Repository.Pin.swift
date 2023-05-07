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
extension Repository.Pin
{
    @inlinable public
    init(id:PackageIdentifier, location:Repository, state:State)
    {
        self.init(id: id,
            reference: state.reference,
            revision: state.revision,
            location: location)
    }
    @inlinable public
    var state:State
    {
        .init(reference: self.reference, revision: self.revision)
    }
}
