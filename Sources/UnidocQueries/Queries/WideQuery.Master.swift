import MongoQL
import UnidocSelectors

extension WideQuery
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
extension WideQuery.Master
{
    var scalars:Scalars { .init(in: self.path) }
}
