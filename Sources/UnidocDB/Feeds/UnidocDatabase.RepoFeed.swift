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

    /// 1 MB ought to be enough for anybody.
    static
    var capacity:(bytes:Int, count:Int?)? { (1 << 20, 16) }

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
extension UnidocDatabase.RepoFeed
{
    public
    func last(_ count:Int,
        with session:Mongo.Session) async throws -> [UnidocDatabase.RepoActivity]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<UnidocDatabase.RepoActivity>>.init(Self.name,
                limit: count)
            {
                $0[.sort] = .init { $0[.natural] = (-) }
            },
            against: self.database)
    }
    public
    func push(_ activity:UnidocDatabase.RepoActivity,
        with session:Mongo.Session) async throws
    {
        try await self.insert(some: activity, with: session)
    }
}
