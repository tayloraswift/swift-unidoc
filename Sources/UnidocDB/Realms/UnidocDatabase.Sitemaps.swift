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

    public
    func list(with session:Mongo.Session, _ yield:([MetadataView]) throws -> Void) async throws
    {
        try await session.run(command: Mongo.Find<Mongo.Cursor<MetadataView>>.init(Self.name,
                stride: 4096)
            {
                $0[.projection] = .init
                {
                    $0[Realm.Sitemap[.modified]] = true
                }
                $0[.sort] = .init
                {
                    $0[Realm.Sitemap[.id]] = (+)
                }
                $0[.hint] = .init
                {
                    $0[Realm.Sitemap[.id]] = (+)
                }
            },
            against: self.database,
            by: .now.advanced(by: .seconds(10)))
        {
            for try await batch:[MetadataView] in $0
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
