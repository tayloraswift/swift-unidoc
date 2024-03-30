import MongoDB
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct BuildTagQuery
    {
        let package:Unidoc.Package
        let version:Unidoc.VersionSeries

        init(package:Unidoc.Package, version:Unidoc.VersionSeries)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.BuildTagQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Packages
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Output>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.id]] = self.package
        }
        pipeline[stage: .replaceWith] = .init(Output.CodingKey.self)
        {
            $0[.package] = Mongo.Pipeline.ROOT
        }

        pipeline.loadTags(series: self.version,
            from: Output[.package],
            into: Output[.version])

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Output[.version]
    }
}
