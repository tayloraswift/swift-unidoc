import MongoQL
import UnidocRecords

extension Unidoc
{
    enum SitemapIndexQuery:Sendable
    {
        case list
    }
}
extension Unidoc.SitemapIndexQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = UnidocDatabase.Sitemaps
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Cursor<Unidoc.SitemapIndexEntry>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.sort] = .init
        {
            $0[Unidoc.Sitemap[.id]] = (+)
        }

        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Unidoc.Sitemap[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.id]
            $0[.as] = Unidoc.SitemapIndexEntry[.symbol]
        }

        pipeline[.unwind] = Unidoc.SitemapIndexEntry[.symbol]

        pipeline[.replaceWith] = .init
        {
            $0[Unidoc.SitemapIndexEntry[.modified]] = Unidoc.Sitemap[.modified]
            $0[Unidoc.SitemapIndexEntry[.symbol]] =
                Unidoc.SitemapIndexEntry[.symbol] / Unidoc.PackageMetadata[.symbol]
        }
    }
}
