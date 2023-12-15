import MongoDB
import UnidocDB

extension Swiftinit
{
    @dynamicMemberLookup
    struct DB:Sendable
    {
        let sessions:Mongo.SessionPool
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
    subscript<Collection>(
        dynamicMember keyPath:KeyPath<UnidocDatabase, Collection>) -> Collection
        where Collection:Mongo.CollectionModel
    {
        self.unidoc[keyPath: keyPath]
    }
}
