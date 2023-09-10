import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Search:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "search" }

    typealias ElementID = VolumeIdentifier

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
