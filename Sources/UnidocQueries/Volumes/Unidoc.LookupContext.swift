import MongoQL
import UnidocRecords

extension Unidoc
{
    public
    protocol LookupContext
    {
        func packages(_:inout Mongo.PipelineEncoder,
            volume:Mongo.AnyKeyPath,
            vertex:Mongo.AnyKeyPath,
            output:Mongo.AnyKeyPath)

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
}
