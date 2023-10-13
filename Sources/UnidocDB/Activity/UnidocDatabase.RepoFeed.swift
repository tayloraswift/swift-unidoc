import BSON
import MongoDB

extension UnidocDatabase
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
extension UnidocDatabase.RepoFeed:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "repo_feed" }

    typealias ElementID = BSON.Millisecond

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
extension UnidocDatabase.RepoFeed:DatabaseCollectionCapped
{
    /// 1 MB ought to be enough for anybody.
    static
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension UnidocDatabase.RepoFeed
{
    public
    func last(_ count:Int,
        with session:Mongo.Session) async throws -> [UnidocDatabase.RepoActivity]
    {
        try await self.find(last: count, with: session)
    }

    public
    func push(_ activity:UnidocDatabase.RepoActivity,
        with session:Mongo.Session) async throws
    {
        try await self.insert(some: activity, with: session)
    }
}
