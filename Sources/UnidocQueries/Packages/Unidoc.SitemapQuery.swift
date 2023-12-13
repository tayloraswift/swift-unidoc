import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct SitemapQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Package

        @inlinable public
        init(package symbol:Symbol.Package)
        {
            self.symbol = symbol
        }
    }
}
extension Unidoc.SitemapQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.SitemapQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = UnidocDatabase.PackageAliases
    public
    typealias CollectionTarget = UnidocDatabase.Packages

    @inlinable public static
    var target:Mongo.KeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Sitemaps.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.Sitemap[.id]
            $0[.as] = Output[.sitemap]
        }

        pipeline[.unwind] = Output[.sitemap]

        pipeline[.set] = .init
        {
            $0[Output[.package]] = Self.target / Unidoc.PackageMetadata[.symbol]
        }
    }
}
