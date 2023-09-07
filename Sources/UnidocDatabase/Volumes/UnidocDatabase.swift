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
struct UnidocDatabase:Identifiable, Sendable
{
    public
    let id:Mongo.Database

    @inlinable public
    init(id:Mongo.Database)
    {
        self.id = id
    }
}
extension UnidocDatabase
{
    var policies:Policies { .init() }

    var masters:Masters { .init(database: self.id) }
    var groups:Groups { .init(database: self.id) }
    var search:Search { .init(database: self.id) }
    var trees:Trees { .init(database: self.id) }
    var names:Names { .init(database: self.id) }
    var siteMaps:SiteMaps { .init(database: self.id) }

    public static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }
}
extension UnidocDatabase:DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.masters.setup(with: session)
        try await self.groups.setup(with: session)
        try await self.search.setup(with: session)
        try await self.trees.setup(with: session)
        try await self.names.setup(with: session)
        try await self.siteMaps.setup(with: session)
    }
}
extension UnidocDatabase
{
    public
    func rebuild(from ecosystem:PackageDatabase,
        with session:__shared Mongo.Session) async throws -> Int
    {
        //  TODO: we need to implement some kind of locking mechanism to prevent
        //  race conditions between rebuilds and pushes. This cannot be done with
        //  MongoDB transactions because deleting a very large number of records
        //  overflows the transaction cache.
        try await self.drop(with: session)
        try await self.setup(with: session)

        print("reinitialized unidoc database...")

        var count:Int = 0

        try await ecosystem.graphs.list(with: session)
        {
            let snapshot:Snapshot = try await ecosystem.graphs.load(from: $0, with: session)
            let volume:Volume = try await self.link(snapshot,
                against: ecosystem,
                with: session)

            try await self.publish(volume, with: session)

            count += 1

            print("regenerated records for snapshot: \(snapshot.id)")
        }

        return count
    }

    public
    func publish(linking docs:__owned Documentation,
        against ecosystem:PackageDatabase,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let receipt:SnapshotReceipt = try await ecosystem.store(docs: docs, with: session)
        let volume:Volume = try await self.link(.init(receipt.zone,
                metadata: docs.metadata,
                graph: docs.graph),
            against: ecosystem,
            with: session)

        if  receipt.overwritten
        {
            try await self.search.delete(volume.id, with: session)

            try await self.masters.clear(receipt.zone, with: session)
            try await self.groups.clear(receipt.zone, with: session)
            try await self.trees.clear(receipt.zone, with: session)

            try await self.names.delete(receipt.zone, with: session)
        }

        try await self.publish(volume, with: session)
        return receipt
    }
}
extension UnidocDatabase
{
    private
    func publish(_ volume:__owned Volume, with session:__shared Mongo.Session) async throws
    {
        let (index, trees):(SearchIndex<VolumeIdentifier>, [Volume.TypeTree]) = volume.indexes()

        try await self.masters.insert(volume.masters, with: session)
        try await self.names.insert(volume.names, with: session)
        try await self.trees.insert(trees, with: session)
        try await self.search.insert(index, with: session)

        if  volume.names.latest
        {
            try await self.siteMaps.upsert(volume.siteMap(), with: session)
            try await self.groups.insert(volume.groups(latest: true), with: session)
        }
        else
        {
            try await self.groups.insert(volume.groups, with: session)
        }
        if  let latest:Unidoc.Zone = volume.latest
        {
            try await self.groups.align(latest: latest, with: session)
            try await self.names.align(latest: latest, with: session)
        }
    }

    private
    func link(_ snapshot:__owned Snapshot,
        against database:PackageDatabase,
        with session:Mongo.Session) async throws -> Volume
    {
        let context:DynamicContext = .init(snapshot,
            dependencies: try await database.graphs.load(snapshot.metadata.pins(),
                with: session))

        let symbolicator:DynamicSymbolicator = .init(context: context,
            root: snapshot.metadata.root)
        let linker:DynamicLinker = .init(context: context)

        symbolicator.emit(linker.errors, colors: .enabled)

        let latest:Names.PatchView? = try await self.names.latest(of: snapshot.cell,
            with: session)

        var volume:Volume = .init(latest: latest?.id,
            masters: linker.masters,
            groups: linker.groups,
            names: linker.names)

        guard let patch:PatchVersion = volume.names.patch
        else
        {
            volume.names.latest = false
            return volume
        }

        if  let latest:PatchVersion = latest?.patch,
                latest > patch
        {
            volume.names.latest = false
        }
        else
        {
            volume.names.latest = true
            volume.latest = volume.names.id
        }

        return volume
    }
}
extension UnidocDatabase
{
    public
    func siteMap(package:__owned PackageIdentifier,
        with session:__shared Mongo.Session) async throws -> Volume.SiteMap<PackageIdentifier>?
    {
        try await self.siteMaps.find(by: package, with: session)
    }
}
extension UnidocDatabase
{
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
