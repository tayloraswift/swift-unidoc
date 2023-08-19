import BSON
import ModuleGraphs
import MongoDB

extension Database
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
extension Database.SiteMaps:DatabaseCollection
{
    public
    typealias ElementID = PackageIdentifier

    @inlinable public static
    var name:Mongo.Collection { "siteMaps" }

    public
    func setup(with session:Mongo.Session) async throws
    {
    }
}
