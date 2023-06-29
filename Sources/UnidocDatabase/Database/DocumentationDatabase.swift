import FNV1
import MongoDB
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

@frozen public
struct DocumentationDatabase
{
    private
    let pool:Mongo.SessionPool
    public
    let name:Mongo.Database

    private
    init(pool:Mongo.SessionPool, name:Mongo.Database)
    {
        self.name = name
        self.pool = pool
    }
}
extension DocumentationDatabase
{
    var policies:Policies { .init() }

    @inlinable public
    var packages:Packages { .init(database: self.name) }
    @inlinable public
    var snapshots:Snapshots { .init(database: self.name) }

    @inlinable public
    var zones:Zones { .init(database: self.name) }
}
extension DocumentationDatabase
{
    public static
    func setup(mongodb pool:__owned Mongo.SessionPool, name:Mongo.Database) async throws -> Self
    {
        let database:Self = .init(pool: pool, name: name)
        try await database.setup()
        return database
    }

    private
    func setup() async throws
    {
        try await self.packages.setup(with: try await .init(from: self.pool))
        try await self.snapshots.setup(with: try await .init(from: self.pool))

        try await self.zones.setup(with: try await .init(from: self.pool))
    }
}
extension DocumentationDatabase
{
    public
    func push(docs:Documentation) async throws -> SnapshotReceipt
    {
        try await self.push(docs: docs, with: try await .init(from: self.pool))
    }
    public
    func push(docs:Documentation, with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        //  TODO: enforce population limits
        try await self.snapshots.push(docs,
            for: try await self.packages.register(docs.metadata.package, with: session),
            as: docs.metadata.id ?? "$anonymous",
            with: session)
    }
}
extension DocumentationDatabase
{
    public
    func publish(docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> SnapshotReceipt
    {
        let (receipt, context):(SnapshotReceipt, DynamicContext) = try await self.pull(
            pushing: docs,
            with: session)

        let linker:DynamicLinker = .init(context: context)
        let output:Records = linker.projection

        let symbolicator:DynamicSymbolicator = .init(context: context, root: docs.metadata.root)
            symbolicator.emit(linker.errors, colors: .enabled)

        try await self.zones.insert(output.zone, with: session)

        return receipt
    }
    private
    func pull(pushing docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> (SnapshotReceipt, DynamicContext)
    {
        let dependencies:[Snapshot] = try await self.snapshots.load(docs.metadata.pins(),
            with: session)

        var upstream:UpstreamScalars = .init()

        for snapshot:Snapshot in dependencies
        {
            for (citizen, symbol):(Int32, Symbol.Decl) in snapshot.graph.citizens
            {
                upstream.citizens[symbol] = snapshot.zone + citizen
            }
            for (culture, symbol):(Int, ModuleIdentifier) in zip(
                snapshot.graph.cultures.indices,
                snapshot.graph.namespaces)
            {
                upstream.cultures[symbol] = snapshot.zone + culture * .module
            }
        }

        let receipt:SnapshotReceipt = try await self.push(docs: docs, with: session)
        let context:DynamicContext = .init(currentSnapshot: .init(from: docs, receipt: receipt),
            upstreamSnapshots: dependencies,
            upstreamSymbols: upstream)
        return (receipt, context)
    }
}
extension DocumentationDatabase
{
    public
    func _get(
        package:PackageIdentifier,
        version:Substring?,
        stem:Substring,
        hash:FNV24?,
        with session:Mongo.Session) async throws
    {
        let zone:Record.Zone? = try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Record.Zone>>.init(Zones.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[Record[.package]] = package
                            $0[Record[.version]] = version
                        }
                    }
                    $0.stage
                    {
                        $0[.sort] = .init
                        {
                            $0[Record[.recency]] = (-)
                        }
                    }
                    $0.stage
                    {
                        $0[.limit] = 1
                    }
                },
                stride: 1)
                {
                    $0[.hint] = .init
                    {
                        $0[Record[.package]] = (+)
                        $0[Record[.version]] = (+)
                        $0[Record[.recency]] = (-)
                    }
                },
            against: self.name)
        {
            try await $0.reduce(into: [], +=).first
        }

        print(zone as Any)
    }
}
