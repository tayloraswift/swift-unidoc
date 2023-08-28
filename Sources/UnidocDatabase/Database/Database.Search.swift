import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct Search
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Search:DatabaseCollection
{
    typealias ElementID = VolumeIdentifier

    @inlinable public static
    var name:Mongo.Collection { "search" }
}
extension Database.Search
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
