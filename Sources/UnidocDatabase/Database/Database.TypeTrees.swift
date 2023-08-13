import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct TypeTrees
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.TypeTrees:DatabaseCollection
{
    typealias ElementID = Unidoc.Scalar

    @inlinable public static
    var name:Mongo.Collection { "typetrees" }
}
extension Database.TypeTrees
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
