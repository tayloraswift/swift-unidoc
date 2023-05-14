import SemanticVersions

extension Repository
{
    @frozen public
    struct Pin:Identifiable, Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:Repository
        public
        let revision:Revision
        public
        let ref:SemanticRef

        @inlinable public
        init(id:PackageIdentifier, location:Repository, revision:Revision, ref:SemanticRef)
        {
            self.id = id
            self.location = location
            self.revision = revision
            self.ref = ref
        }
    }
}
extension Repository.Pin
{
    @inlinable public
    init(id:PackageIdentifier, location:Repository, state:State)
    {
        self.init(id: id,
            location: location,
            revision: state.revision,
            ref: state.ref)
    }
    @inlinable public
    var state:State
    {
        .init(revision: self.revision, ref: self.ref)
    }
}
