import BSON
import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct DocsFeed
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
extension UnidocDatabase.DocsFeed:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "docs_feed" }

    typealias ElementID = BSON.Millisecond

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
extension UnidocDatabase.DocsFeed:DatabaseCollectionCapped
{
    /// 1 MB ought to be enough for anybody.
    static
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension UnidocDatabase.DocsFeed
{
    public
    func push(_ activity:UnidocDatabase.DocsActivity<Unidoc.Zone>,
        with session:Mongo.Session) async throws
    {
        try await self.insert(some: activity, with: session)
    }
}
