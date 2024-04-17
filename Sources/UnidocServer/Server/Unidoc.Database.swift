import MongoDB
import UnidocDB

extension Unidoc
{
    @dynamicMemberLookup
    @frozen public
    struct Database:Sendable
    {
        public
        let sessions:Mongo.SessionPool
        public
        let unidoc:Unidoc.DB
        public
        let policy:Policy

        @inlinable public
        init(sessions:Mongo.SessionPool, unidoc:Unidoc.DB, policy:Policy = .init())
        {
            self.sessions = sessions
            self.unidoc = unidoc
            self.policy = policy
        }
    }
}
extension Unidoc.Database
{
    @inlinable public
    init(sessions:Mongo.SessionPool,
        unidoc:Unidoc.DB,
        configure:(inout Policy) throws -> Void) rethrows
    {
        var policy:Policy = .init()
        try configure(&policy)
        self.init(sessions: sessions, unidoc: unidoc, policy: policy)
    }
}
extension Unidoc.Database
{
    @inlinable public
    subscript<Collection>(
        dynamicMember keyPath:KeyPath<Unidoc.DB, Collection>) -> Collection
        where Collection:Mongo.CollectionModel
    {
        self.unidoc[keyPath: keyPath]
    }
}
