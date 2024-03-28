import MongoDB
import UnidocAPI
import UnidocDB

extension Unidoc
{
    @frozen public
    struct BuildTagQuery
    {
        @usableFromInline
        let package:Unidoc.Package
        @usableFromInline
        let version:Unidoc.VersionSeries

        @inlinable public
        init(package:Unidoc.Package, version:Unidoc.VersionSeries)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.BuildTagQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Packages
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.Single<Output>

    public
    var hint:Mongo.CollectionIndex? { nil }

    public
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
    }
}
