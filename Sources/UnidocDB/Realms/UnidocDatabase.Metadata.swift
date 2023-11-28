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
    @inlinable public static
    var name:Mongo.Collection { "Metadata" }

    typealias ElementID = Int32

    static
    var indexes:[Mongo.CollectionIndex] { [] }
}
