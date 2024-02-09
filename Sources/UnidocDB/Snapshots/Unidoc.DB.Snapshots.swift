import BSON
import MongoDB
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI
import UnidocLinker
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Snapshots
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
extension Unidoc.DB.Snapshots
{
    public static
    let indexSwiftReleases:Mongo.CollectionIndex = .init("SwiftReleases",
        unique: true)
    {
        $0[Unidoc.Snapshot[.swift]] = (-)
    }
        where:
    {
        $0[Unidoc.Snapshot[.swift]] { $0[.exists] = true }
    }

    public static
    let indexUplinking:Mongo.CollectionIndex = .init("Uplinking",
        unique: false)
    {
        $0[Unidoc.Snapshot[.link]] = (+)
    }
        where:
    {
        $0[Unidoc.Snapshot[.link]] { $0[.exists] = true }
    }
}
extension Unidoc.DB.Snapshots:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.Snapshot

    @inlinable public static
    var name:Mongo.Collection { "Snapshots" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexSwiftReleases,
            Self.indexUplinking,
        ]
    }
}
extension Unidoc.DB.Snapshots
{
    public
    func upsert(snapshot:Unidoc.Snapshot,
        with session:Mongo.Session) async throws -> Unidoc.UploadStatus
    {
        switch try await self.upsert(some: snapshot, with: session)
        {
        case nil:   .init(edition: snapshot.id, updated: true)
        case  _?:   .init(edition: snapshot.id, updated: false)
        }
    }
}
extension Unidoc.DB.Snapshots
{
    func load(for snapshot:Unidoc.Snapshot,
        from loader:(some Unidoc.GraphLoader)?,
        pins:[Unidoc.Edition],
        with session:Mongo.Session) async throws -> Unidoc.Linker
    {
        var objects:[SymbolGraphObject<Unidoc.Edition>] = []
            objects.reserveCapacity(1 + pins.count)

        if  snapshot.metadata.package.name != .swift,
            let swift:Unidoc.Snapshot = try await self.loadStandardLibrary(with: session)
        {
            objects.append(try await swift.load(with: loader))
        }

        for other:Unidoc.Snapshot in try await self.load(pins, with: session)
        {
            objects.append(try await other.load(with: loader))
        }

        let missing:Set<Unidoc.Edition> = objects.reduce(into: .init(pins))
        {
            $0.remove($1.id)
        }
        for missing:Unidoc.Edition in missing.sorted(by: { $0.package < $1.package })
        {
            print("warning: could not load snapshot dependency '\(missing)'")
        }

        return .init(linking: try await snapshot.load(with: loader), against: objects)
    }
}
extension Unidoc.DB.Snapshots
{
    private
    func loadStandardLibrary(
        with session:Mongo.Session) async throws -> Unidoc.Snapshot?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.Snapshot>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Unidoc.Snapshot[.swift]] { $0[.exists] = true }
                }
                $0[.sort] = .init
                {
                    $0[Unidoc.Snapshot[.swift]] = (-)
                }
            },
            against: self.database)
    }

    private
    func load(_ pins:[Unidoc.Edition],
        with session:Mongo.Session) async throws -> [Unidoc.Snapshot]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Unidoc.Snapshot>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter] = .init
                {
                    $0[Unidoc.Snapshot[.id]] { $0[.in] = pins }
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [], +=)
        }
    }
}
extension Unidoc.DB.Snapshots
{
    public
    func linkable(_ limit:Int,
        with session:Mongo.Session) async throws -> [Unidoc.Edition]
    {
        let editions:[Mongo.IdentityView<Unidoc.Edition>] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Mongo.IdentityView<Unidoc.Edition>>>.init(
                Self.name,
                limit: limit)
            {
                $0[.filter] = .init
                {
                    $0[Unidoc.Snapshot[.link]] { $0[.exists] = true }
                }
                $0[.projection] = .init
                {
                    $0[Unidoc.Snapshot[.id]] = true
                }

                $0[.hint] = Self.indexUplinking.id
            },
            against: self.database)

        return editions.map(\.id)
    }
}