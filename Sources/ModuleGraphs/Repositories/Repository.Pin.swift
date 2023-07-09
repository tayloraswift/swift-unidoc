import SemanticVersions

extension Repository
{
    @frozen public
    struct Pin:Identifiable, Equatable, Hashable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let location:Repository
        public
        let revision:Revision
        public
        let version:AnyVersion

        @inlinable public
        init(id:PackageIdentifier, location:Repository, revision:Revision, version:AnyVersion)
        {
            self.id = id
            self.location = location
            self.revision = revision
            self.version = version
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
            version: state.version)
    }
    @inlinable public
    var state:State
    {
        .init(revision: self.revision, version: self.version)
    }
}
