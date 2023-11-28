import MongoDB
import Symbols
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct PackageAliases
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
extension UnidocDatabase.PackageAliases:Mongo.CollectionModel
{
    public
    typealias ElementID = Symbol.Package

    @inlinable public static
    var name:Mongo.Collection { "PackageAliases" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("Coordinate")
        {
            $0[Realm.PackageAlias[.coordinate]] = (+)
        },
    ]
}
