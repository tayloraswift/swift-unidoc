import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidex
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
extension Unidex.SitemapQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidex.SitemapQuery:Unidex.AliasingQuery
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
            $0[.foreignField] = Unidex.Sitemap[.id]
            $0[.as] = Output[.sitemap]
        }

        pipeline[.unwind] = Output[.sitemap]

        pipeline[.set] = .init
        {
            $0[Output[.package]] = Self.target / Unidoc.PackageMetadata[.symbol]
        }
    }
}
