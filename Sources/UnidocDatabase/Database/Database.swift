import FNV1
import MongoDB
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc
import UnidocLinker
import UnidocRecords

@frozen public
struct Database:Identifiable, Sendable
{
    public
    let id:Mongo.Database

    private
    init(id:Mongo.Database)
    {
        self.id = id
    }
}
extension Database
{
    var policies:Policies { .init() }

    @inlinable public
    var packages:Packages { .init(database: self.id) }
    @inlinable public
    var snapshots:Snapshots { .init(database: self.id) }

    @inlinable public
    var extensions:Extensions { .init(database: self.id) }
    @inlinable public
    var masters:Masters { .init(database: self.id) }
    @inlinable public
    var zones:Zones { .init(database: self.id) }
}
extension Database
{
    public static
    func setup(_ id:Mongo.Database, in pool:__owned Mongo.SessionPool) async throws -> Self
    {
        let database:Self = .init(id: id)
        try await database.setup(with: try await .init(from: pool))
        return database
    }

    private
    func setup(with session:Mongo.Session) async throws
    {
        try await self.packages.setup(with: session)
        try await self.snapshots.setup(with: session)

        try await self.extensions.setup(with: session)
        try await self.masters.setup(with: session)
        try await self.zones.setup(with: session)
    }
}
extension Database
{
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
extension Database
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

        try await self.extensions.insert(output.extensions, with: session)
        try await self.masters.insert(output.masters, with: session)
        try await self.zones.insert(output.zone, with: session)

        return receipt
    }
    private
    func pull(pushing docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> (SnapshotReceipt, DynamicContext)
    {
        let dependencies:[Snapshot] = try await self.snapshots.load(docs.metadata.pins(),
            with: session)

        var upstream:DynamicContext.UpstreamScalars = .init()

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
            upstreamScalars: upstream)
        return (receipt, context)
    }
}
extension Database
{
    public
    func _get(
        package:PackageIdentifier,
        version:Substring?,
        stem:String,
        hash:FNV24?,
        with session:Mongo.Session) async throws
    {
        _ = try await self.execute(query: .init(
                package: package,
                version: version,
                stem: stem,
                hash: hash),
            with: session)
    }
    public
    func execute(query:__owned DocpageQuery, with session:Mongo.Session) async throws -> String?
    {
        // try await session.run(
        //     command: Mongo.Explain<Mongo.Aggregate<Mongo.Cursor<PageFacets.Direct>>>.init(
        //         verbosity: .executionStats,
        //         command: query.command),
        //     against: self.name)

        let page:Docpage? = try await session.run(
            command: query.command,
            against: self.id)
        {
            try await $0.reduce(into: [], +=).first
        }

        if  let page:Docpage
        {
            let _string:String = "\(page)"
            print(_string)
            return _string
        }
        else
        {
            print("no results!")
            return nil
        }
    }
}
