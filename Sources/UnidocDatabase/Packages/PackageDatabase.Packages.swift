import GitHubIntegration
import JSONEncoding
import ModuleGraphs
import MongoDB
import UnidocAnalysis
import UnidocRecords

extension PackageDatabase
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
extension PackageDatabase.Packages:DatabaseCollection
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
                $0[PackageRecord[.cell]] = (-)
            }
        },
    ]
}
extension PackageDatabase.Packages
{
    /// Registers the given package identifier in the database, returning its cell.
    /// This is really just a glorified string internment system.
    ///
    /// This function can be expensive. It only makes one query if the package is already
    /// registered, but can take two round trips to intern the identifier otherwise.
    public
    func register(_ package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Int32
    {
        try await self.register(package, updating: nil, tracking: nil, with: session).cell
    }

    func register(_ package:PackageIdentifier,
        updating meta:PackageDatabase.Meta?,
        tracking repo:PackageRepo?,
        with session:Mongo.Session) async throws -> Placement
    {
        var placement:Placement = try await self.place(package: package, with: session)
        let record:PackageRecord = .init(id: package, cell: placement.cell, repo: repo)

        if  placement.new
        {
            //  This can fail if we race with another process.
            try await self.insert(record, with: session)

        }
        else if case _? = repo
        {
            try await self.update(record, with: session)
            placement.repo = repo
        }

        if  let meta:PackageDatabase.Meta, placement.new
        {
            //  Update the list of all packages.
            try await meta.upsert(try await self.scan(with: session), with: session)
        }

        return placement
    }

    func place(package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Placement
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
                    $0[PackageRecord[.id]] = package
                }
            }
            $0.stage
            {
                $0[.replaceWith] = .init
                {
                    $0[Placement[.cell]] = PackageRecord[.cell]
                    $0[Placement[.repo]] = PackageRecord[.repo]
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
                                $0[PackageRecord[.cell]] = (-)
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
                                $0[Placement[.cell]] = .expr
                                {
                                    $0[.add] = (PackageRecord[.cell], 1)
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
                    $0[Placement[.cell]] = (+)
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

    @discardableResult
    public
    func update(_ package:Int32,
        repo:PackageRepo,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: PackageRecord[.repo],
            by: PackageRecord[.cell],
            of: package,
            to: repo,
            with: session)
    }

    private
    func scan(with session:Mongo.Session) async throws -> SearchIndex<Int32>
    {
        //  TODO: this should project the `_id`
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<PackageRecord>>.init(Self.name, stride: 1024),
                against: self.database)
            {
                for try await batch:[PackageRecord] in $0
                {
                    for cell:PackageRecord in batch
                    {
                        json[+] = "\(cell.id)"
                    }
                }
            }
        }

        return .init(id: 0, json: json)
    }
}
