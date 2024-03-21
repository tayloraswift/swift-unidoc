import MongoQL
import UnidocRecords

extension Unidoc
{
    public
    protocol VertexPredicate:Equatable, Hashable, Sendable
    {
        func extend(pipeline:inout Mongo.PipelineEncoder,
            volume:Mongo.AnyKeyPath,
            output:Mongo.AnyKeyPath,
            unset:[Mongo.AnyKeyPath])
    }
}
