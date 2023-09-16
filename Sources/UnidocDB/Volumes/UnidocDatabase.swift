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
}
extension UnidocDatabase:DatabaseModel
{
    @inlinable public static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }

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

        var origins:[Int32: Volume.Names.Origin?] = [:]
        var count:Int = 0

        try await ecosystem.graphs.list(with: session)
        {
            (snapshot:Snapshot) in

            let origin:Volume.Names.Origin? = try await
            {
                switch $0
                {
                case let origin??:
                    return origin

                case nil?:
                    //  We already tried to find the origin for this package, and it
                    //  didn't exist.
                    return nil

                case nil:
                    let package:PackageRecord? = try await ecosystem.packages.find(
                        by: PackageRecord[.cell],
                        of: snapshot.package,
                        with: session)
                    let origin:Volume.Names.Origin? = package?.repo?.origin
                    $0 = .some(origin)
                    return origin
                }
            } (&origins[snapshot.package])

            let volume:Volume = try await self.link(snapshot,
                against: ecosystem,
                origin: origin,
                with: session)

            try await self.publish(volume, with: session)

            count += 1

            print("regenerated records for snapshot: \(snapshot.id)")
        }

        return count
    }

    public
    func publish(linking docs:__owned SymbolGraphArchive,
        against ecosystem:PackageDatabase,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let receipt:SnapshotReceipt = try await ecosystem.store(docs: docs, with: session)
        let volume:Volume = try await self.link(.init(
                package: receipt.package,
                version: receipt.version,
                metadata: docs.metadata,
                graph: docs.graph),
            against: ecosystem,
            origin: receipt.repo?.origin,
            with: session)

        if  case .update = receipt.type
        {
            try await self.search.delete(volume.id, with: session)

            try await self.masters.clear(receipt.edition, with: session)
            try await self.groups.clear(receipt.edition, with: session)
            try await self.trees.clear(receipt.edition, with: session)

            try await self.names.delete(receipt.edition, with: session)
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
        origin:__owned Volume.Names.Origin?,
        with session:Mongo.Session) async throws -> Volume
    {
        let context:DynamicContext = .init(snapshot,
            dependencies: try await database.graphs.load(snapshot.metadata.pins(),
                with: session))

        let symbolicator:DynamicSymbolicator = .init(context: context,
            root: snapshot.metadata.root)
        let linker:DynamicLinker = .init(context: context)

        symbolicator.emit(linker.errors, colors: .enabled)

        let latestRelease:Names.PatchView? = try await self.names.latestRelease(
            of: snapshot.package,
            with: session)

        let id:Snapshot.ID = snapshot.id

        var volume:Volume = .init(latest: latestRelease?.id,
            masters: linker.masters,
            groups: linker.groups,
            names: .init(id: snapshot.edition,
                display: snapshot.metadata.display,
                refname: snapshot.metadata.commit?.refname,
                origin: origin,
                volume: id.volume,
                latest: true,
                patch: id.version.stable?.patch))

        guard case .stable(.release(let patch, build: _)) = id.version.canonical
        else
        {
            volume.names.latest = false
            volume.names.patch = nil
            return volume
        }

        if  let latest:PatchVersion = latestRelease?.patch,
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
