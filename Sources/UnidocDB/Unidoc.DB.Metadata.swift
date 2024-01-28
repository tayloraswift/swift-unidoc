import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB
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
extension Unidoc.DB.Metadata:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.TextResource<Key>

    @inlinable public static
    var name:Mongo.Collection { "Metadata" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
