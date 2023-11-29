import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Search
    {
        public
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Search:Mongo.CollectionModel
{
    public
    typealias Element = SearchIndex<VolumeIdentifier>

    @inlinable public static
    var name:Mongo.Collection { "VolumeSearch" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
