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
        let unidoc:UnidocDatabase

        init(sessions:Mongo.SessionPool, unidoc:UnidocDatabase)
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
        dynamicMember keyPath:KeyPath<UnidocDatabase, Collection>) -> Collection
        where Collection:Mongo.CollectionModel
    {
        self.unidoc[keyPath: keyPath]
    }
}
