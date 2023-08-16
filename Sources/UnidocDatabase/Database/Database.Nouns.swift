import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct Nouns
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Nouns:DatabaseCollection
{
    typealias ElementID = Unidoc.Zone

    @inlinable public static
    var name:Mongo.Collection { "nouns" }
}
extension Database.Nouns
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
