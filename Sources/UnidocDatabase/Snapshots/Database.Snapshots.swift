import MongoDB
import SymbolGraphs
import Unidoc
import UnidocLinker

extension Database
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
extension Database.Snapshots
{
    @inlinable public static
    var name:Mongo.Collection { "snapshots" }

    func setup(with session:Mongo.Session) async throws
    {
        let response:Mongo.CreateIndexesResponse = try await session.run(
            command: Mongo.CreateIndexes.init(Self.name,
                writeConcern: .majority,
                indexes:
                [
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] =
                        """
                        \(Self.name)\
                        (\(Snapshot[.package]), \(Snapshot[.version]))
                        """
                        $0[.key] = .init
                        {
                            $0[Snapshot[.package]] = (-)
                            $0[Snapshot[.version]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    public
    func push(_ docs:Documentation,
        for package:Int32,
        as id:String,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let result:Mongo.TransactionResult = await session.withSnapshotTransaction(
            writeConcern: .majority)
        {
            try await self.push(docs, for: package, as: id, with: $0)
        }
        return try result()
    }

    func push(_ docs:Documentation,
        for package:Int32,
        as id:String,
        with transaction:Mongo.Transaction) async throws -> SnapshotReceipt
    {
        //  Look up the snapshot with the highest version index in the database
        let predecessors:[MetadataView] = try await transaction.run(
            command: Mongo.Find<Mongo.SingleBatch<MetadataView>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Snapshot[.package]] = package
                }
                $0[.sort] = .init
                {
                    $0[Snapshot[.version]] = (-)
                }
                $0[.hint] = .init
                {
                    $0[Snapshot[.package]] = (-)
                    $0[Snapshot[.version]] = (-)
                }
                $0[.projection] = .init
                {
                    $0[Snapshot[.package]] = true
                    $0[Snapshot[.version]] = true
                }
            },
            against: self.database)

        let predecessor:Int32 = predecessors.first?.version ?? -1
        if  predecessor == .max
        {
            fatalError("unimplemented")
        }

        let snapshot:Snapshot = .init(id: id,
            package: package,
            version: predecessor + 1,
            metadata: docs.metadata,
            graph: docs.graph)

        let response:Mongo.UpdateResponse<String> = try await transaction.run(
            command: Mongo.Update<Mongo.One, String>.init(Self.name,
                updates: [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.q] = .init
                        {
                            $0[Snapshot[.id]] = snapshot.id
                        }
                        $0[.u] = snapshot
                    },
                ]),
            against: self.database)

        return .init(overwritten: response.upserted.isEmpty,
            package: package,
            version: snapshot.version,
            id: id)
    }
}
extension Database.Snapshots
{
    func load(_ zone:Unidoc.Zone, with session:Mongo.Session) async throws -> Snapshot
    {
        let snapshots:[Snapshot] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Snapshot>>.init(Self.name, limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Snapshot[.package]] = zone.package
                    $0[Snapshot[.version]] = zone.version
                }
                $0[.hint] = .init
                {
                    $0[Snapshot[.package]] = (-)
                    $0[Snapshot[.version]] = (-)
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
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Snapshot>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter] = .init
                {
                    $0[Snapshot[.stable]] = true
                    $0[Snapshot[.id]] = .init
                    {
                        $0[.in] = pins
                    }
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [], +=)
        }
    }
    /// Returns the zone tuples for all snapshots in this collection, with respect
    /// to the read concern of the given transaction.
    func list(with transaction:Mongo.Transaction) async throws -> [Unidoc.Zone]
    {
        try await transaction.run(
            command: Mongo.Find<Mongo.Cursor<MetadataView>>.init(Self.name,
                stride: 4096,
                limit: .max)
            {
                $0[.projection] = .init
                {
                    $0[Snapshot[.package]] = true
                    $0[Snapshot[.version]] = true
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [])
            {
                for metadata:MetadataView in $1
                {
                    $0.append(metadata.zone)
                }
            }
        }
    }
}
