import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Trees:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "trees" }

    typealias ElementID = Unidoc.Scalar

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
