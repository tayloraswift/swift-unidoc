import MongoQL
import UnidocRecords

extension Unidoc
{
    public
    typealias VertexPredicate = _UnidocVertexPredicate
}

/// The name of this protocol is ``Unidoc.VertexPredicate``.
public
protocol _UnidocVertexPredicate:Equatable, Hashable, Sendable
{
    func extend(pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        output:Mongo.KeyPath)
}
