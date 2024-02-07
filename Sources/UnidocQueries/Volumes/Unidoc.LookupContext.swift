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
    func groups(_:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        vertex:Mongo.AnyKeyPath,
        output:Mongo.AnyKeyPath)

    func edges(_:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        vertex:Mongo.AnyKeyPath,
        groups:Mongo.AnyKeyPath,
        output:(scalars:Mongo.AnyKeyPath, volumes:Mongo.AnyKeyPath))
}
