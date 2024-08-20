import BSON
import MongoDB
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
extension Unidoc.DB.Metadata:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.TextResource<Key>

    @inlinable public static
    var name:Mongo.Collection { "Metadata" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
