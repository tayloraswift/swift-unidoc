import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Trees
    {
        public
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Unidoc.DB.Trees:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.TypeTree

    @inlinable public static
    var name:Mongo.Collection { "VolumeTrees" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
