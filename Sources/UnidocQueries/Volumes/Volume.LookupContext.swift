import MongoQL
import UnidocRecords

extension Volume
{
    public
    typealias LookupContext = _VolumeLookupContext
}

/// The name of this protocol is ``Volume.LookupContext``.
public
protocol _VolumeLookupContext
{
    static
    func groups(_:inout Mongo.PipelineStage,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        output:Mongo.KeyPath)

    static
    func edges(_:inout Mongo.PipelineStage,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        groups:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
}
