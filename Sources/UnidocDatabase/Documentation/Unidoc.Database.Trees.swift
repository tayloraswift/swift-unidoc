import MongoDB
import Unidoc
import UnidocRecords

extension Unidoc.Database
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
extension Unidoc.Database.Trees:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "trees" }

    typealias ElementID = Unidoc.Scalar

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
