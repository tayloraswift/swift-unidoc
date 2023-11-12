import GitHubAPI
import JSONEncoding
import ModuleGraphs
import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Packages
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
extension UnidocDatabase.Packages:DatabaseCollection
{
    public
    typealias ElementID = PackageIdentifier

    @inlinable public static
    var name:Mongo.Collection { "packages" }

    public static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true
            $0[.name] = "cell"
            $0[.key] = .init
            {
                $0[Realm.Package[.coordinate]] = (+)
            }
        },
        .init
        {
            $0[.unique] = false
            $0[.name] = "crawled"
            $0[.key] = .init
            {
                $0[Realm.Package[.crawled]] = (+)
            }

            $0[.partialFilterExpression] = .init
            {
                $0[Realm.Package[.repo]] = .init { $0[.exists] = true }
            }
        },
    ]
}
extension UnidocDatabase.Packages:RecodableCollection
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Realm.Package.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Packages
{
    public
    func stalest(_ limit:Int, with session:Mongo.Session) async throws -> [Realm.Package]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Realm.Package>>.init(Self.name,
                limit: limit)
            {
                $0[.filter] = .init
                {
                    $0[Realm.Package[.repo]] = .init { $0[.exists] = true }
                }
                $0[.sort] = .init
                {
                    $0[Realm.Package[.crawled]] = (+)
                }
                $0[.hint] = .init
                {
                    $0[Realm.Package[.crawled]] = (+)
                }
            },
            against: self.database)
    }

    public
    func update(record:Realm.Package, with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(some: record, with: session)
    }

    public
    func find(by coordinate:Int32, with session:Mongo.Session) async throws -> Realm.Package?
    {
        try await self.find(by: Realm.Package[.coordinate], of: coordinate, with: session)
    }
}
extension UnidocDatabase.Packages
{
    /// Registers the given package identifier in the database, returning its package
    /// coordinate. This is really just a glorified string internment system.
    ///
    /// This function can be expensive. It only makes one query if the package is already
    /// registered, but can take two round trips to intern the identifier otherwise.
    func register(_ package:PackageIdentifier,
        updating meta:UnidocDatabase.Meta,
        tracking repo:consuming Realm.Repo?,
        with session:Mongo.Session) async throws -> Realm.Package
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Placement = try await self.place(package: package, with: session)
        let package:Realm.Package = .init(id: package,
            coordinate: placement.coordinate,
            realm: placement.realm ?? .united,
            repo: repo)

        if  placement.new
        {
            //  This can fail if we race with another process.
            try await self.insert(some: package, with: session)
            //  Regenerate the JSON list of all packages.
            try await meta.upsert(some: try await self.scan(with: session), with: session)
        }
        else if
            let repo:Realm.Repo = package.repo,
                repo != placement.repo
        {
            try await self.update(some: package, with: session)
        }

        return package
    }

    func place(package:PackageIdentifier, with session:Mongo.Session) async throws -> Placement
    {
        //  This used to be a transaction, but we cannot use `$unionWith` in a transaction,
        //  and transactions aren’t going to scale for what we need to do afterwards.
        //  (e.g. regenerating the all-package search index.)
        let pipeline:Mongo.Pipeline = .init
        {
            $0.stage
            {
                $0[.match] = .init
                {
                    $0[Realm.Package[.id]] = package
                }
            }
            $0.stage
            {
                $0[.replaceWith] = .init
                {
                    $0[Placement[.coordinate]] = Realm.Package[.coordinate]
                    //  After we migrate the schema, `new` will become redundant, and we
                    //  can use the existence of `realm` to indicate newness.
                    $0[Placement[.realm]] = Realm.Package[.realm]
                    $0[Placement[.repo]] = Realm.Package[.repo]
                    $0[Placement[.new]] = false
                }
            }
            $0.stage
            {
                $0[.unionWith] = .init
                {
                    $0[.collection] = Self.name
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.sort] = .init
                            {
                                $0[Realm.Package[.coordinate]] = (-)
                            }
                        }
                        $0.stage
                        {
                            $0[.limit] = 1
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Placement[.coordinate]] = .expr
                                {
                                    $0[.add] = (Realm.Package[.coordinate], 1)
                                }
                                $0[Placement[.new]] = true
                            }
                        }
                    }
                }
            }
            //  Prefer existing registrations, if any.
            $0.stage
            {
                $0[.sort] = .init
                {
                    $0[Placement[.coordinate]] = (+)
                }
            }
            $0.stage
            {
                $0[.limit] = 1
            }
        }

        let placement:[Placement] = try await session.run(
            command: Mongo.Aggregate<Mongo.SingleBatch<Placement>>.init(Self.name,
                pipeline: pipeline),
            against: self.database)

        //  If there are no results, the collection is completely uninitialized,
        //  and we should start the count from zero.
        return placement.first ?? .first
    }

    private
    func scan(with session:Mongo.Session) async throws -> SearchIndex<Int32>
    {
        //  TODO: this should project the `_id`
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Realm.Package>>.init(Self.name, stride: 1024),
                against: self.database)
            {
                for try await batch:[Realm.Package] in $0
                {
                    for cell:Realm.Package in batch
                    {
                        json[+] = "\(cell.id)"
                    }
                }
            }
        }

        return .init(id: 0, json: json)
    }
}
