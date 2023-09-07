import MongoDB
import SymbolGraphs
import Unidoc
import UnidocLinker

extension PackageDatabase
{
    @frozen public
    struct Graphs
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
extension PackageDatabase.Graphs:DatabaseCollection
{
    public
    typealias ElementID = String

    @inlinable public static
    var name:Mongo.Collection { "symbolgraphs" }

    public static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true // for now...
            $0[.name] = "zone"
            $0[.key] = .init
            {
                $0[Snapshot[.zone]] = (+)
            }
        },
    ]
}

extension PackageDatabase.Graphs
{
    func list(with session:Mongo.Session,
        _ yield:(Unidoc.Zone) async throws -> ()) async throws
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<ZoneView>>.init(Self.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.group] = .init
                        {
                            $0[.id] = Snapshot[.zone]
                        }
                    }
                },
                stride: 4096),
            against: self.database)
        {
            for try await batch:[ZoneView] in $0
            {
                for view:ZoneView in batch
                {
                    try await yield(view.zone)
                }
            }
        }
    }
}
extension PackageDatabase.Graphs
{
    func store(_ docs:Documentation,
        into zone:Unidoc.Zone,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let snapshot:Snapshot = .init(zone, metadata: docs.metadata, graph: docs.graph)

        let response:Mongo.UpdateResponse<String> = try await session.run(
            command: Mongo.Update<Mongo.One, String>.init(Self.name,
                updates: [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.hint] = .init
                        {
                            $0[Snapshot[.zone]] = (+)
                        }
                        $0[.q] = .init
                        {
                            $0[Snapshot[.zone]] = zone
                        }
                        $0[.u] = snapshot
                    },
                ]),
            against: self.database)

        return .init(id: snapshot.id, zone: zone, overwritten: response.upserted.isEmpty)
    }
}
extension PackageDatabase.Graphs
{
    func load(from zone:Unidoc.Zone, with session:Mongo.Session) async throws -> Snapshot
    {
        let snapshots:[Snapshot] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Snapshot>>.init(Self.name, limit: 1)
            {
                $0[.hint] = .init
                {
                    $0[Snapshot[.zone]] = (+)
                }
                $0[.filter] = .init
                {
                    $0[Snapshot[.zone]] = zone
                }
            },
            against: self.database)

        if  let snapshot:Snapshot = snapshots.first
        {
            return snapshot
        }
        else
        {
            throw RetrievalError.init(zone: zone)
        }
    }

    func load(_ pins:[String], with session:Mongo.Session) async throws -> [Snapshot]
    {
        let snapshots:[Snapshot] = try await session.run(
            command: Mongo.Find<Mongo.Cursor<Snapshot>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter] = .init
                {
                    $0[Snapshot[.id]] = .init { $0[.in] = pins }
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [], +=)
        }

        let missing:Set<String> = snapshots.reduce(into: .init(pins)) { $0.remove($1.id) }
        for missing:String in missing.sorted()
        {
            print("warning: could not load snapshot dependency '\(missing)'")
        }

        return snapshots
    }
}
