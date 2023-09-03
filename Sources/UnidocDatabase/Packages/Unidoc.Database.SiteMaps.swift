import BSON
import ModuleGraphs
import MongoQL

extension Unidoc.Database
{
    @frozen public
    struct SiteMaps
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
extension Unidoc.Database.SiteMaps:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "siteMaps" }

    typealias ElementID = PackageIdentifier

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
