import BSON
import MongoDB

extension Unidoc.DB
{
    @frozen public
    struct RepoFeed
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
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
    func last(_ count:Int) async throws -> [Activity]
    {
        try await self.find(last: count)
    }

    public
    func push(_ activity:Activity) async throws
    {
        try await self.insert(some: activity)
    }
}
