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
                        $0[.name] = "package,version"
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

    func push(_ docs:Documentation,
        for package:Int32,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let result:Mongo.TransactionResult = await session.withSnapshotTransaction(
            writeConcern: .majority)
        {
            try await self.push(docs, for: package, with: $0)
        }
        return try result()
    }

    func push(_ docs:Documentation,
        for package:Int32,
        with transaction:Mongo.Transaction) async throws -> SnapshotReceipt
    {
        let version:Int32 = try await self.version(docs.metadata.id,
            package: package,
            with: transaction)

        let snapshot:Snapshot = .init(
            package: package,
            version: version,
            metadata: docs.metadata,
            graph: docs.graph)

        let response:Mongo.UpdateResponse<String> = try await transaction.run(
            command: Mongo.Update<Mongo.One, String>.init(Self.name,
                updates: [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.hint] = .init
                        {
                            $0[Snapshot[.package]] = (-)
                            $0[Snapshot[.version]] = (-)
                        }
                        $0[.q] = .init
                        {
                            $0[Snapshot[.package]] = package
                            $0[Snapshot[.version]] = version
                        }
                        $0[.u] = snapshot
                    },
                ]),
            against: self.database)

        return .init(overwritten: response.upserted.isEmpty,
            package: package,
            version: snapshot.version,
            id: snapshot.id)
    }
}
extension Database.Snapshots
{
    private
    func version(_ id:String,
        package:Int32,
        with transaction:Mongo.Transaction) async throws -> Int32
    {
        let pipeline:Mongo.Pipeline = .init
        {
            let predecessor:Mongo.KeyPath = "predecessor"
            let existing:Mongo.KeyPath = "existing"
            let zone:Mongo.KeyPath = "zone"

            $0.stage
            {
                $0[.match] = .init
                {
                    $0[Snapshot[.package]] = package
                }
            }
            $0.stage
            {
                $0[.facet] = .init
                {
                    $0[predecessor] = .init
                    {
                        $0.stage
                        {
                            $0[.sort] = .init
                            {
                                $0[Snapshot[.version]] = (-)
                            }
                        }
                        $0.stage
                        {
                            $0[.limit] = 1
                        }
                        $0.stage
                        {
                            $0[.set] = .init
                            {
                                $0[Snapshot[.version]] = .expr
                                {
                                    $0[.add] = (Snapshot[.version], 1)
                                }
                            }
                        }
                    }
                    $0[existing] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[Snapshot[.id]] = id
                            }
                        }
                    }
                }
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[zone] = .expr { $0[.concatArrays] = (predecessor, existing) }
                }
            }
            $0.stage
            {
                $0[.unwind] = zone
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[Snapshot[.version]] = zone / Snapshot[.version]
                }
            }
            $0.stage
            {
                //  If a snapshot with the same revision already exists, return that first.
                $0[.sort] = .init
                {
                    $0[Snapshot[.version]] = (+)
                }
            }
            $0.stage
            {
                $0[.project] = .init
                {
                    $0[Snapshot[.version]] = 1
                }
            }
            $0.stage
            {
                $0[.limit] = 1
            }
        }

        return try await transaction.run(
            command: Mongo.Aggregate<Mongo.Cursor<VersionView>>.init(Self.name,
                pipeline: pipeline,
                stride: 1),
            against: self.database)
        {
            try await $0.reduce(into: [], +=).first?.version ?? 0
        }
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
        let snapshots:[Snapshot] = try await session.run(
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

        let missing:Set<String> = snapshots.reduce(into: .init(pins)) { $0.remove($1.id) }
        for missing:String in missing.sorted()
        {
            print("warning: could not load snapshot dependency '\(missing)'")
        }

        return snapshots
    }

    /// Returns the zone tuples for all snapshots in this collection.
    func list(with session:Mongo.Session) async throws -> [Unidoc.Zone]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<MetadataView>>.init(Self.name,
                stride: 4096,
                limit: .max)
            {
                $0[.projection] = .init
                {
                    $0[Snapshot[.id]] = false
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
