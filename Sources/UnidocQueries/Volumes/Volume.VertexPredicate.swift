import MongoQL
import UnidocRecords

extension Volume
{
    public
    typealias VertexPredicate = _VolumeVertexPredicate
}

/// The name of this protocol is ``Volume.VertexPredicate``.
public
protocol _VolumeVertexPredicate:Equatable, Hashable, Sendable
{
    func stage(_:inout Mongo.PipelineStage, input:Mongo.KeyPath, output:Mongo.KeyPath)
}
