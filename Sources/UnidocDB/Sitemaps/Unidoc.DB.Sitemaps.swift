import BSON
import MongoDB
import MongoQL
import Symbols
import UnidocRecords

extension Unidoc.DB
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
extension Unidoc.DB.Sitemaps:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.Sitemap

    @inlinable public static
    var name:Mongo.Collection { "Sitemaps" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}

extension Unidoc.DB.Sitemaps
{
    public
    func list(with session:Mongo.Session,
        _ yield:([Unidoc.SitemapIndexEntry]) throws -> Void) async throws
    {
        try await session.run(command: Unidoc.SitemapIndexQuery.list.command(stride: 4096),
            against: self.database,
            by: .now.advanced(by: .seconds(10)))
        {
            for try await batch:[Unidoc.SitemapIndexEntry] in $0
            {
                try yield(batch)
            }
        }
    }

    func diff(new:Unidoc.Sitemap,
        with session:Mongo.Session) async throws -> Unidoc.SitemapDelta?
    {
        guard
        let old:Unidoc.Sitemap = try await self.find(id: new.id, with: session)
        else
        {
            return nil
        }

        //  Compute sitemap delta.
        var deletions:Set<Unidoc.Shoot> = .init(old.elements)
        var additions:[Unidoc.Shoot] = []

        for page:Unidoc.Shoot in new.elements
        {
            if  case nil = deletions.remove(page)
            {
                additions.append(page)
            }
        }

        return .init(deletions: deletions.sorted(), additions: additions)
    }
}
