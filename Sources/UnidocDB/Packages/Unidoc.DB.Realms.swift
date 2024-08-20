import MongoDB
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Realms
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
extension Unidoc.DB.Realms:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.RealmMetadata

    @inlinable public static
    var name:Mongo.Collection { "Realms" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
