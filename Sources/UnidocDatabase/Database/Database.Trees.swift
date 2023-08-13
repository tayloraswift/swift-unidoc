import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct Trees
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Trees:DatabaseCollection
{
    typealias ElementID = Unidoc.Scalar

    @inlinable public static
    var name:Mongo.Collection { "trees" }
}
extension Database.Trees
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
