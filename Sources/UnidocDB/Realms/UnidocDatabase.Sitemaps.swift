import BSON
import MongoDB
import MongoQL
import Symbols
import UnidocRecords
import UnixTime

extension UnidocDatabase
{
    @frozen public
    struct Sitemaps
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Sitemaps:Mongo.CollectionModel
{
    @inlinable public static
    var name:Mongo.Collection { "Sitemaps" }

    public
    typealias ElementID = Int32

    public static
    var indexes:[Mongo.CollectionIndex] { [] }
}

extension UnidocDatabase.Sitemaps
{
    // public
    // func find(by package:Symbol.Package,
    //     with session:Mongo.Session) async throws -> Realm.Sitemap?
    // {
    //     try await self.find(Realm.Sitemap.self, by: package, with: session)
    // }

    public
    func list(with session:Mongo.Session,
        _ yield:([Realm.SitemapIndexEntry]) throws -> Void) async throws
    {
        try await session.run(command: Realm.SitemapIndexQuery.list.command(stride: 4096),
            against: self.database,
            by: .now.advanced(by: .seconds(10)))
        {
            for try await batch:[Realm.SitemapIndexEntry] in $0
            {
                try yield(batch)
            }
        }
    }

    func update(_ sitemap:consuming Realm.Sitemap,
        with session:Mongo.Session) async throws -> Realm.Sitemap.Delta?
    {
        var new:Realm.Sitemap = sitemap
        let old:Realm.Sitemap? = try await self.find(by: new.id, with: session)

        let update:Realm.Sitemap.Delta?
        if  let old:Realm.Sitemap
        {
            //  Compute sitemap delta.
            var deletions:Set<Volume.Shoot> = .init(old.elements)
            var additions:Int = 0

            for page:Volume.Shoot in new.elements
            {
                if  case nil = deletions.remove(page)
                {
                    additions += 1
                }
            }

            let delta:Realm.Sitemap.Delta = .init(
                deletions: deletions.sorted(),
                additions: additions)

            if  case .zero = delta
            {
                //  We can skip the update entirely.
                return delta
            }
            else
            {
                update = delta
                new.modified = .now()
            }
        }
        else
        {
            update = nil
        }

        try await self.upsert(some: new, with: session)
        return update
    }
}
