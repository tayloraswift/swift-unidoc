import MongoQL
import UnidocRecords

extension Realm
{
    enum SitemapIndexQuery:Sendable
    {
        case list
    }
}
extension Realm.SitemapIndexQuery:Mongo.PipelineQuery
{
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Cursor<Realm.SitemapIndexEntry>

    var origin:Mongo.Collection { UnidocDatabase.Sitemaps.name }
    var hint:Mongo.SortDocument? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.sort] = .init
        {
            $0[Realm.Sitemap[.id]] = (+)
        }

        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Realm.Sitemap[.id]
            $0[.foreignField] = Realm.Package[.id]
            $0[.as] = Realm.SitemapIndexEntry[.symbol]
        }

        pipeline[.unwind] = Realm.SitemapIndexEntry[.symbol]

        pipeline[.replaceWith] = .init
        {
            $0[Realm.SitemapIndexEntry[.modified]] = Realm.Sitemap[.modified]
            $0[Realm.SitemapIndexEntry[.symbol]] =
                Realm.SitemapIndexEntry[.symbol] / Realm.Package[.symbol]
        }
    }
}
