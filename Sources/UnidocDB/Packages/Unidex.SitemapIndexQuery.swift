import MongoQL
import UnidocRecords

extension Unidex
{
    enum SitemapIndexQuery:Sendable
    {
        case list
    }
}
extension Unidex.SitemapIndexQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = UnidocDatabase.Sitemaps
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Cursor<Unidex.SitemapIndexEntry>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.sort] = .init
        {
            $0[Unidex.Sitemap[.id]] = (+)
        }

        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Unidex.Sitemap[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.id]
            $0[.as] = Unidex.SitemapIndexEntry[.symbol]
        }

        pipeline[.unwind] = Unidex.SitemapIndexEntry[.symbol]

        pipeline[.replaceWith] = .init
        {
            $0[Unidex.SitemapIndexEntry[.modified]] = Unidex.Sitemap[.modified]
            $0[Unidex.SitemapIndexEntry[.symbol]] =
                Unidex.SitemapIndexEntry[.symbol] / Unidoc.PackageMetadata[.symbol]
        }
    }
}
