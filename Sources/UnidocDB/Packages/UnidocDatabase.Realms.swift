import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Realms
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
extension UnidocDatabase.Realms:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.RealmMetadata

    @inlinable public static
    var name:Mongo.Collection { "Realms" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
