import MongoDB
import UnidocDB

extension Swiftinit
{
    @dynamicMemberLookup
    @frozen public
    struct DB:Sendable
    {
        public
        let sessions:Mongo.SessionPool
        public
        let unidoc:Unidoc.DB

        @inlinable public
        init(sessions:Mongo.SessionPool, unidoc:Unidoc.DB)
        {
            self.sessions = sessions
            self.unidoc = unidoc
        }
    }
}
extension Swiftinit.DB
{
    @inlinable public
    subscript<Collection>(
        dynamicMember keyPath:KeyPath<Unidoc.DB, Collection>) -> Collection
        where Collection:Mongo.CollectionModel
    {
        self.unidoc[keyPath: keyPath]
    }
}
