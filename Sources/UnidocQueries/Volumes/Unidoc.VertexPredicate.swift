import MongoQL
import UnidocRecords

extension Unidoc
{
    public
    protocol VertexPredicate:Equatable, Hashable, Sendable
    {
        func lookup(_ lookup:inout Mongo.LookupEncoder,
            volume:Mongo.AnyKeyPath,
            output:Mongo.AnyKeyPath,
            fields:VertexProjection)
    }
}
