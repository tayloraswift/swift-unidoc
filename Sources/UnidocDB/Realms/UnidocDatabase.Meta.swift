import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    /// A single-document collection containing a ``SearchIndex``.
    @frozen public
    struct Meta
    {
        public
        let database:Mongo.Database

        @inlinable public
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Meta:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "meta" }

    typealias ElementID = Int32

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}