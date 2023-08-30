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
    @inlinable public static
    var name:Mongo.Collection { "search" }

    typealias ElementID = VolumeIdentifier

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
