import FNV1
import MongoDB
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAnalysis
import UnidocLinker
import UnidocSelectors
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

    var masters:Masters { .init(database: self.id) }
    var groups:Groups { .init(database: self.id) }
    var trees:Trees { .init(database: self.id) }
    var zones:Zones { .init(database: self.id) }


    public static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }
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
        do
        {
            try await self.packages.setup(with: session)
            try await self.snapshots.setup(with: session)

            try await self.masters.setup(with: session)
            try await self.groups.setup(with: session)
            try await self.trees.setup(with: session)
            try await self.zones.setup(with: session)
        }
        catch let error
        {
            print("""
                warning: some indexes are no longer valid. \
                the database likely needs to be rebuilt.
                """)
            print(error)
        }
    }
}
extension Database
{
    /// Drops and reinitializes the database. This destroys *all* its data!
    public
    func nuke(with session:Mongo.Session) async throws
    {
        try await session.run(command: Mongo.DropDatabase.init(), against: self.id)
        try await self.setup(with: session)
    }
}
extension Database
{
    public
    func rebuild(with session:__shared Mongo.Session) async throws -> Int
    {
        //  TODO: we need to implement some kind of locking mechanism to prevent
        //  race conditions between rebuilds and pushes. This cannot be done with
        //  MongoDB transactions because deleting a very large number of records
        //  overflows the transaction cache.
        let zones:[Unidoc.Zone] = try await self.snapshots.list(with: session)

        try await self.masters.replace(with: session)
        try await self.groups.replace(with: session)
        try await self.trees.replace(with: session)
        try await self.zones.replace(with: session)

        for zone:Unidoc.Zone in zones
        {
            let snapshot:Snapshot = try await self.snapshots.load(zone, with: session)
            let records:Records = try await self.pull(from: snapshot, with: session)

            try await self.push(records, with: session)

            print("regenerated records for snapshot: \(snapshot.id)")
        }

        return zones.count
    }

    public
    func publish(docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> SnapshotReceipt
    {
        let receipt:SnapshotReceipt = try await self.store(docs: docs, with: session)
        let records:Records = try await self.pull(from: .init(
                package: receipt.package,
                version: receipt.version,
                metadata: docs.metadata,
                graph: docs.graph),
            with: session)

        if  receipt.overwritten
        {
            try await self.masters.clear(receipt.zone, with: session)
            try await self.groups.clear(receipt.zone, with: session)
            try await self.trees.clear(receipt.zone, with: session)

            try await self.zones.delete(receipt.zone, with: session)
        }

        try await self.push(records, with: session)
        return receipt
    }
}
extension Database
{
    public
    func store(docs:Documentation, with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        //  TODO: enforce population limits
        try await self.snapshots.push(docs,
            for: try await self.packages.register(docs.metadata.package, with: session),
            with: session)
    }
    private
    func pull(from snapshot:__owned Snapshot,
        with session:__shared Mongo.Session) async throws -> Records
    {
        let context:DynamicContext = .init(snapshot,
            dependencies: try await self.snapshots.load(snapshot.metadata.pins(),
                with: session))

        let symbolicator:DynamicSymbolicator = .init(context: context,
            root: snapshot.metadata.root)
        let linker:DynamicLinker = .init(context: context)

        symbolicator.emit(linker.errors, colors: .enabled)

        let latest:Zones.PatchView? = try await self.zones.latest(of: snapshot.cell,
            with: session)

        var records:Records = .init(latest: latest?.id,
            masters: linker.masters,
            groups: linker.groups,
            zone: linker.zone)

        guard let patch:PatchVersion = records.zone.patch
        else
        {
            records.zone.latest = false
            return records
        }

        if  let latest:PatchVersion = latest?.patch,
                latest > patch
        {
            records.zone.latest = false
        }
        else
        {
            records.zone.latest = true
            records.latest = records.zone.id
        }

        return records
    }
    private
    func push(_ records:__owned Records,
        with session:__shared Mongo.Session) async throws
    {
        let trees:[Record.TypeTree] = records._buildTypeTrees()

        try await self.masters.insert(records.masters, with: session)
        try await self.trees.insert(trees, with: session)

        try await self.zones.insert(records.zone, with: session)

        if  records.zone.latest
        {
            try await self.groups.insert(records.groups(latest: true), with: session)
        }
        else
        {
            try await self.groups.insert(records.groups, with: session)
        }
        if  let latest:Unidoc.Zone = records.latest
        {
            try await self.groups.align(latest: latest, with: session)
            try await self.zones.align(latest: latest, with: session)
        }
    }
}
extension Database
{
    //  This should be part of the swift-mongodb package.
    private
    func explain<Command>(command:__owned Command,
        with session:Mongo.Session) async throws -> String
        where Command:MongoCommand
    {
        try await session.run(
            command: Mongo.Explain<Command>.init(
                verbosity: .executionStats,
                command: command),
            against: self.id)
    }

    public
    func explain<Query>(query:__owned Query,
        with session:Mongo.Session) async throws -> String
        where Query:DatabaseQuery
    {
        try await self.explain(command: query.command, with: session)
    }

    @inlinable public
    func execute<Query>(query:__owned Query,
        with session:Mongo.Session) async throws -> Query.Output?
        where Query:DatabaseQuery
    {
        try await session.run(command: query.command, against: self.id)
    }
}
