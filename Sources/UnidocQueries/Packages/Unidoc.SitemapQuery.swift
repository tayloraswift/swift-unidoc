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
extension Unidoc.SitemapQuery:Unidoc.AliasingQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Sitemaps.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.Sitemap[.id]
            $0[.as] = Output[.sitemap]
        }

        pipeline[stage: .unwind] = Output[.sitemap]

        pipeline[stage: .set, using: Output.CodingKey.self]
        {
            $0[.package] = Self.target / Unidoc.PackageMetadata[.symbol]
        }
    }
}
