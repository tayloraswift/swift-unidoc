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
extension UnidocDatabase.Search:Mongo.CollectionModel
{
    @inlinable public static
    var name:Mongo.Collection { "VolumeSearch" }

    typealias ElementID = VolumeIdentifier

    static
    var indexes:[Mongo.CollectionIndex] { [] }
}
