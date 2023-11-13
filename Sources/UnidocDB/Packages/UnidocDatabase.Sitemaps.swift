import BSON
import ModuleGraphs
import MongoDB
import MongoQL
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
extension UnidocDatabase.Sitemaps:DatabaseCollection
{
    //  TODO: rename collection to `sitemap`.
    @inlinable public static
    var name:Mongo.Collection { "siteMaps" }

    public
    typealias ElementID = PackageIdentifier

    public static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
extension UnidocDatabase.Sitemaps
{
    public
    func find(by package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Realm.Sitemap?
    {
        try await self.find(Realm.Sitemap.self, by: package, with: session)
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
            var additions:[Volume.Shoot] = []

            for page:Volume.Shoot in new.elements
            {
                if  case nil = deletions.remove(page)
                {
                    additions.append(page)
                }
            }

            let delta:Realm.Sitemap.Delta = .init(
                deletions: deletions.sorted(),
                additions: additions.count)

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
