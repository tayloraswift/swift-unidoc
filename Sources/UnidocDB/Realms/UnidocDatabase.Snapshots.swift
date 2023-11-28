import BSONEncoding
import MongoDB
import SymbolGraphs
import Symbols
import Unidoc
import UnidocLinker
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Snapshots:Mongo.CollectionModel
{
    public
    typealias ElementID = Unidoc.Edition

    @inlinable public static
    var name:Mongo.Collection { "Snapshots" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("SwiftReleases", unique: true)
        {
            $0[Realm.Snapshot[.swift]] = (-)
        }
            where:
        {
            $0[Realm.Snapshot[.swift]] = .init { $0[.exists] = true }
        },
    ]
}
extension UnidocDatabase.Snapshots
{
    public
    func find(id:Unidoc.Edition, with session:Mongo.Session) async throws -> Realm.Snapshot?
    {
        try await self.find(by: id, with: session)
    }

    public
    func upsert(snapshot:Realm.Snapshot,
        with session:Mongo.Session) async throws -> UnidocDatabase.Uploaded
    {
        switch try await self.upsert(some: snapshot, with: session)
        {
        case nil:   .init(edition: snapshot.id, updated: true)
        case  _?:   .init(edition: snapshot.id, updated: false)
        }
    }
}
extension UnidocDatabase.Snapshots
{
    func load(for snapshot:Realm.Snapshot,
        pins:[Unidoc.Edition],
        with session:Mongo.Session) async throws -> DynamicContext
    {
        var dependencies:[Realm.Snapshot] = try await self.load(pins, with: session)

        if  snapshot.metadata.package != .swift,
            let swift:Realm.Snapshot = try await self.loadStandardLibrary(with: session)
        {
            dependencies.append(swift)
        }

        let missing:Set<Unidoc.Edition> = dependencies.reduce(into: .init(pins))
        {
            $0.remove($1.id)
        }
        for missing:Unidoc.Edition in missing.sorted(by: { $0.package < $1.package })
        {
            print("warning: could not load snapshot dependency '\(missing)'")
        }

        return .init(snapshot, dependencies: dependencies)
    }
}
extension UnidocDatabase.Snapshots
{
    private
    func loadStandardLibrary(
        with session:Mongo.Session) async throws -> Realm.Snapshot?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Realm.Snapshot>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Realm.Snapshot[.swift]] = .init { $0[.exists] = true }
                }
                $0[.sort] = .init
                {
                    $0[Realm.Snapshot[.swift]] = (-)
                }
            },
            against: self.database)
    }

    private
    func load(_ pins:[Unidoc.Edition],
        with session:Mongo.Session) async throws -> [Realm.Snapshot]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Realm.Snapshot>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter] = .init
                {
                    $0[Realm.Snapshot[.id]] = .init { $0[.in] = pins }
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [], +=)
        }
    }
}
