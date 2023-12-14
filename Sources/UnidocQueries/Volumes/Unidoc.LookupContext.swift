import MongoQL
import UnidocRecords

extension Unidoc
{
    public
    typealias LookupContext = _UnidocLookupContext
}

/// The name of this protocol is ``Unidoc.LookupContext``.
public
protocol _UnidocLookupContext
{
    static
    func groups(_:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        output:Mongo.KeyPath)

    static
    func edges(_:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        groups:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
}
