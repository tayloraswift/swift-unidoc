import BSONEncoding
import ModuleGraphs
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
    typealias ElementID = Snapshot.ID

    @inlinable public static
    var name:Mongo.Collection { "symbolgraphs" }

    public static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true // for now...
            $0[.name] = "package,version"
            $0[.key] = .init
            {
                $0[Snapshot[.package]] = (-)
                $0[Snapshot[.version]] = (-)
            }
        },
        .init
        {
            $0[.unique] = true // for now...
            $0[.name] = "metadata_package,version"
            $0[.key] = .init
            {
                $0[Snapshot[.metadata] / SymbolGraphMetadata[.package]] = (-)
                $0[Snapshot[.version]] = (-)
            }
        },
    ]
}

extension PackageDatabase.Graphs
{
    func list(package:Int32? = nil,
        with session:Mongo.Session,
        _ yield:(Snapshot) async throws -> ()) async throws
    {
        try await self.list(package: package, version: nil, with: session, yield)
    }

    func list(edition:Unidoc.Zone,
        with session:Mongo.Session,
        _ yield:(Snapshot) async throws -> ()) async throws
    {
        try await self.list(
            package: edition.package,
            version: edition.version,
            with: session,
            yield)
    }

    private
    func list(
        package:Int32?,
        version:Int32?,
        with session:Mongo.Session,
        _ yield:(Snapshot) async throws -> ()) async throws
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Snapshot>>.init(Self.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[Snapshot[.package]] = package
                            $0[Snapshot[.version]] = version
                        }
                    }
                },
                stride: 1)
            {
                if  case _? = package
                {
                    $0[.hint] = .init
                    {
                        $0[Snapshot[.package]] = (-)
                        $0[Snapshot[.version]] = (-)
                    }
                }
            },
            against: self.database)
        {
            for try await batch:[Snapshot] in $0
            {
                for snapshot:Snapshot in batch
                {
                    try await yield(snapshot)
                }
            }
        }
    }
}
extension PackageDatabase.Graphs
{
    public
    func metadata(
        package:PackageIdentifier,
        limit:Int = 1,
        with session:Mongo.Session) async throws -> [SymbolGraphMetadata]
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.SingleBatch<SymbolGraphMetadata>>.init(Self.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[Snapshot[.metadata] / SymbolGraphMetadata[.package]] = package
                        }
                    }

                    $0.stage
                    {
                        $0[.sort] = .init
                        {
                            $0[Snapshot[.version]] = (-)
                        }
                    }

                    $0.stage
                    {
                        $0[.limit] = limit
                    }

                    $0.stage
                    {
                        $0[.replaceWith] = Snapshot[.metadata]
                    }
                })
            {
                $0[.hint] = .init
                {
                    $0[Snapshot[.metadata] / SymbolGraphMetadata[.package]] = (-)
                    $0[Snapshot[.version]] = (-)
                }
            },
            against: self.database)
    }
}
extension PackageDatabase.Graphs
{
    @available(*, deprecated)
    func load(from edition:Unidoc.Zone, with session:Mongo.Session) async throws -> Snapshot
    {
        let snapshots:[Snapshot] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Snapshot>>.init(Self.name, limit: 1)
            {
                $0[.hint] = .init
                {
                    $0[Snapshot[.package]] = (-)
                    $0[Snapshot[.version]] = (-)
                }
                $0[.filter] = .init
                {
                    $0[Snapshot[.package]] = edition.package
                    $0[Snapshot[.version]] = edition.version
                }
            },
            against: self.database)

        if  let snapshot:Snapshot = snapshots.first
        {
            return snapshot
        }
        else
        {
            throw RetrievalError.init(zone: edition)
        }
    }

    func load(_ pins:[Snapshot.ID], with session:Mongo.Session) async throws -> [Snapshot]
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

        let missing:Set<Snapshot.ID> = snapshots.reduce(into: .init(pins)) { $0.remove($1.id) }
        for missing:Snapshot.ID in missing.sorted(by: { $0.package < $1.package })
        {
            print("warning: could not load snapshot dependency '\(missing)'")
        }

        return snapshots
    }
}
