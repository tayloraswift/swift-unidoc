import MongoQL
import Symbols
import UnidocRecords

extension Unidoc.DB
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
extension Unidoc.DB.Search:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.TextResource<Symbol.Edition>

    @inlinable public static
    var name:Mongo.Collection { "VolumeSearch" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
