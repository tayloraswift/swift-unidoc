import MongoDB
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
    typealias CollectionOrigin = Unidoc.DB.Sitemaps
    typealias Iteration = Mongo.Cursor<Unidoc.SitemapIndexEntry>

    var collation:Mongo.Collation { .simple }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .sort, using: Unidoc.Sitemap.CodingKey.self]
        {
            $0[.id] = (+)
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Packages.name
            $0[.localField] = Unidoc.Sitemap[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.id]
            $0[.as] = Unidoc.SitemapIndexEntry[.symbol]
        }

        pipeline[stage: .unwind] = Unidoc.SitemapIndexEntry[.symbol]

        pipeline[stage: .replaceWith] = .init
        {
            $0[Unidoc.SitemapIndexEntry[.modified]] = Unidoc.Sitemap[.modified]
            $0[Unidoc.SitemapIndexEntry[.symbol]] =
                Unidoc.SitemapIndexEntry[.symbol] / Unidoc.PackageMetadata[.symbol]
        }
    }
}
