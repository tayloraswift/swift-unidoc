import BSON
import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    /// A single-document collection containing a ``SearchIndex``.
    @frozen public
    struct Metadata
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
extension UnidocDatabase.Metadata:Mongo.CollectionModel
{
    public
    typealias Element = SearchIndex<Int32>

    @inlinable public static
    var name:Mongo.Collection { "Metadata" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
