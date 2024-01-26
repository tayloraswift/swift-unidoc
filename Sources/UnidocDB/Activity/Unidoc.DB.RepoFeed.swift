import BSON
import MongoDB

extension Unidoc.DB
{
    @frozen public
    struct RepoFeed
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Unidoc.DB.RepoFeed:Mongo.CollectionModel
{
    public
    typealias Element = Activity

    @inlinable public static
    var name:Mongo.Collection { "RepoFeed" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }

    /// 1 MB ought to be enough for anybody.
    @inlinable public
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension Unidoc.DB.RepoFeed
{
    public
    func last(_ count:Int, with session:Mongo.Session) async throws -> [Activity]
    {
        try await self.find(last: count, with: session)
    }

    public
    func push(_ activity:Activity, with session:Mongo.Session) async throws
    {
        try await self.insert(some: activity, with: session)
    }
}
