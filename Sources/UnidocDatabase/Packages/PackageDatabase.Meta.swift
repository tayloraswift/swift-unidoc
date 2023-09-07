import MongoQL
import Unidoc
import UnidocRecords

extension PackageDatabase
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
extension PackageDatabase.Meta:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "meta" }

    typealias ElementID = Never?

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
