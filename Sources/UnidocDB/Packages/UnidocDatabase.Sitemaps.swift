import BSON
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
    public
    typealias Element = Unidex.Sitemap

    @inlinable public static
    var name:Mongo.Collection { "Sitemaps" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}

extension UnidocDatabase.Sitemaps
{
    public
    func list(with session:Mongo.Session,
        _ yield:([Unidex.SitemapIndexEntry]) throws -> Void) async throws
    {
        try await session.run(command: Unidex.SitemapIndexQuery.list.command(stride: 4096),
            against: self.database,
            by: .now.advanced(by: .seconds(10)))
        {
            for try await batch:[Unidex.SitemapIndexEntry] in $0
            {
                try yield(batch)
            }
        }
    }

    func update(_ sitemap:consuming Unidex.Sitemap,
        with session:Mongo.Session) async throws -> Unidex.Sitemap.Delta?
    {
        var new:Unidex.Sitemap = sitemap
        let old:Unidex.Sitemap? = try await self.find(id: new.id, with: session)

        let update:Unidex.Sitemap.Delta?
        if  let old:Unidex.Sitemap
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

            let delta:Unidex.Sitemap.Delta = .init(
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
