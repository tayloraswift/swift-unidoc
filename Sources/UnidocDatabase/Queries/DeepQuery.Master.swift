import MongoSchema
import UnidocQueries

extension DeepQuery
{
    struct Master
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
extension DeepQuery.Master
{
    var scalars:Scalars { .init(in: self.path) }
    var zones:Zones { .init(in: self.path) }
}
