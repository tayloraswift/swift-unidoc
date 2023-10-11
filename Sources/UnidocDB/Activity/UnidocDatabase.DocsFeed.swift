import BSON
import MongoDB

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

    /// 1 MB ought to be enough for anybody.
    static
    var capacity:(bytes:Int, count:Int?)? { (1 << 20, 16) }

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
