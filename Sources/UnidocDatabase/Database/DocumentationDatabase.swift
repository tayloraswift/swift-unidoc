import MongoDB
import ModuleGraphs
import SymbolGraphs
import Symbols

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

        var linker:DynamicLinker = .init(context: context)
        let _:[ScalarProjection] = linker.project()

        let symbolicator:DynamicSymbolicator = .init(context: context, root: docs.metadata.root)
            symbolicator.emit(diagnoses: linker.diagnoses, colors: .enabled)

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
                upstream.citizens[symbol] = snapshot.translator[citizen: citizen]
            }
            for (culture, symbol):(Int, ModuleIdentifier) in zip(
                snapshot.graph.cultures.indices,
                snapshot.graph.namespaces)
            {
                upstream.cultures[symbol] = snapshot.translator[culture: culture]
            }
        }

        let receipt:SnapshotReceipt = try await self.push(docs: docs, with: session)
        let context:DynamicContext = .init(currentSnapshot: .init(from: docs, receipt: receipt),
            upstreamSnapshots: dependencies,
            upstreamSymbols: upstream)
        return (receipt, context)
    }
}
