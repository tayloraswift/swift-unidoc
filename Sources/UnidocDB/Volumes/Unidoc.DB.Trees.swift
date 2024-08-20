import MongoDB
import Unidoc
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Trees
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
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
