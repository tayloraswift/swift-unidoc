import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Realm
{
    @frozen public
    struct SitemapQuery:Equatable, Hashable, Sendable
    {
        public
        let package:Symbol.Package

        @inlinable public
        init(package:Symbol.Package)
        {
            self.package = package
        }
    }
}
extension Realm.SitemapQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Realm.SitemapQuery:Realm.PackageQuery
{
    @inlinable public static
    var package:Mongo.KeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Sitemaps.name
            $0[.localField] = Output[.package] / Realm.Package[.id]
            $0[.foreignField] = Realm.Sitemap[.id]
            $0[.as] = Output[.sitemap]
        }

        pipeline[.unwind] = Output[.sitemap]

        pipeline[.set] = .init
        {
            $0[Output[.package]] = Output[.package] / Realm.Package[.symbol]
        }
    }
}
