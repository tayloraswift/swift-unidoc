import BSON
import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct RealmAliases
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
extension UnidocDatabase.RealmAliases
{
    public static
    let indexCoordinate:Mongo.CollectionIndex = .init("Coordinate",
        unique: false)
    {
        $0[Unidoc.RealmAlias[.coordinate]] = (+)
    }
}
extension UnidocDatabase.RealmAliases:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.RealmAlias

    @inlinable public static
    var name:Mongo.Collection { "RealmAliases" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexCoordinate] }
}
