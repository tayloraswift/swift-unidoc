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

    var extensions:Extensions { .init(database: self.id) }
    var masters:Masters { .init(database: self.id) }
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
    func publish(docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> SnapshotReceipt
    {
        let receipt:SnapshotReceipt = try await self.push(docs: docs, with: session)

        try await self.pull(from: .init(id: receipt.id,
                package: receipt.package,
                version: receipt.version,
                metadata: docs.metadata,
                graph: docs.graph),
            with: session)

        return receipt
    }

    public
    func rebuild(with session:__shared Mongo.Session) async throws -> Int
    {
        //  TODO: we need to implement some kind of locking mechanism to prevent
        //  race conditions between rebuilds and pushes. This cannot be done with
        //  MongoDB transactions because deleting a very large number of records
        //  overflows the transaction cache.
        let zones:[Unidoc.Zone] = try await self.snapshots.list(with: session)

        try await self.extensions.clear(with: session)
        try await self.masters.clear(with: session)
        try await self.zones.clear(with: session)

        for zone:Unidoc.Zone in zones
        {
            let snapshot:Snapshot = try await self.snapshots.load(zone, with: session)
            try await self.pull(from: snapshot,with: session)

            print("regenerated records for snapshot: \(snapshot.id)")
        }

        return zones.count
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
    private
    func pull(from snapshot:__owned Snapshot,
        with session:__shared Mongo.Session) async throws
    {
        let context:DynamicContext = .init(snapshot,
            dependencies: try await self.snapshots.load(snapshot.metadata.pins(),
                with: session))

        let linker:DynamicLinker = .init(context: context)
        let output:Records = linker.projection

        let symbolicator:DynamicSymbolicator = .init(context: context,
            root: snapshot.metadata.root)

        symbolicator.emit(linker.errors, colors: .enabled)

        try await self.extensions.insert(output.extensions, with: session)
        try await self.masters.insert(output.masters, with: session)
        try await self.zones.insert(output.zone, with: session)
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
