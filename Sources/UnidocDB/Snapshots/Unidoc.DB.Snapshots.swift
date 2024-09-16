import BSON
import MongoDB
import SemanticVersions
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
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
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
    let indexSymbolGraphABI:Mongo.CollectionIndex = .init("ABI/2",
        unique: false)
    {
        $0[Unidoc.Snapshot[.vintage]] = (+)
        $0[Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]] = (+)
    }

    public static
    let indexPendingActions:Mongo.CollectionIndex = .init("Uplinking",
        unique: false)
    {
        $0[Unidoc.Snapshot[.action]] = (+)
    }
        where:
    {
        $0[Unidoc.Snapshot[.action]] { $0[.exists] = true }
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
            Self.indexSymbolGraphABI,
            Self.indexPendingActions,
        ]
    }
}
extension Unidoc.DB.Snapshots
{
    func store(snapshot:Unidoc.Snapshot) async throws -> Unidoc.UploadStatus
    {
        switch try await self.upsert(snapshot)
        {
        case nil:   .init(edition: snapshot.id, updated: true)
        case  _?:   .init(edition: snapshot.id, updated: false)
        }
    }
}
extension Unidoc.DB.Snapshots
{
    func load(for snapshot:Unidoc.Snapshot,
        from loader:(some Unidoc.GraphLoader)?) async throws -> Unidoc.Linker
    {
        let exonyms:[Unidoc.Edition: Symbol.Package] = snapshot.exonyms()
        var objects:[SymbolGraphObject<Unidoc.Edition>] = []
            objects.reserveCapacity(1 + exonyms.count)

        if  snapshot.metadata.package.name != .swift,
            let swift:Unidoc.Snapshot = try await self.loadStandardLibrary()
        {
            objects.append(try await swift.load(with: loader))
        }

        for other:Unidoc.Snapshot in try await self.load(exonyms.keys.sorted())
        {
            var object:SymbolGraphObject<Unidoc.Edition> = try await other.load(with: loader)
            if  let exonym:Symbol.Package = exonyms[other.id]
            {
                object.metadata.package.name = exonym
                object.metadata.package.scope = nil
            }
            objects.append(object)
        }

        let missing:[Unidoc.Edition: Symbol.Package] = objects.reduce(into: exonyms)
        {
            $0[$1.id] = nil
        }
        for missing:Symbol.Package in missing.values.sorted()
        {
            print("""
                warning: could not load pinned dependency '\(missing)' for \
                snapshot '\(snapshot.metadata.package.name)'
                """)
        }

        return .init(linking: try await snapshot.load(with: loader), against: objects)
    }
}
extension Unidoc.DB.Snapshots
{
    private
    func loadStandardLibrary() async throws -> Unidoc.Snapshot?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.Snapshot>>.init(Self.name,
                limit: 1)
            {
                $0[.filter]
                {
                    $0[Unidoc.Snapshot[.swift]] { $0[.exists] = true }
                }
                $0[.sort]
                {
                    $0[Unidoc.Snapshot[.swift]] = (-)
                }
            },
            against: self.database)
    }

    private
    func load(_ pins:[Unidoc.Edition]) async throws -> [Unidoc.Snapshot]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Unidoc.Snapshot>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter]
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
    @discardableResult
    public
    func queueAll(for action:Unidoc.LinkerAction) async throws -> Int
    {
        try await self.updateMany
        {
            $0
            {
                $0[.multi] = true
                $0[.q]
                {
                    $0[Unidoc.Snapshot[.action]] { $0[.exists] = false }
                }
                $0[.u]
                {
                    $0[.set]
                    {
                        $0[Unidoc.Snapshot[.action]] = action
                    }
                }
            }
        }
    }

    @discardableResult
    public
    func queue(id:Unidoc.Edition, for action:Unidoc.LinkerAction) async throws -> Bool?
    {
        try await self.update
        {
            $0
            {
                $0[.q]
                {
                    $0[Unidoc.Snapshot[.action]] { $0[.exists] = false }
                    $0[Unidoc.Snapshot[.id]] = id
                }
                $0[.u]
                {
                    $0[.set]
                    {
                        $0[Unidoc.Snapshot[.action]] = action
                    }
                }
            }
        }
    }

    /// Clears the **queued action** for a single snapshot. Does not delete the snapshot!
    @discardableResult
    public
    func clear(id:Unidoc.Edition) async throws -> Bool?
    {
        try await self.update
        {
            $0
            {
                $0[.q] { $0[Unidoc.Snapshot[.id]] = id }
                $0[.u]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.Snapshot[.action]] = ()
                    }
                }
            }
        }
    }

    @discardableResult
    public
    func mark(id:Unidoc.Edition, vintage:Bool) async throws -> Bool?
    {
        try await self.update
        {
            $0
            {
                $0[.q] { $0[Unidoc.Snapshot[.id]] = id }
                $0[.u]
                {
                    if  vintage
                    {
                        $0[.set]
                        {
                            $0[Unidoc.Snapshot[.vintage]] = true
                        }
                    }
                    else
                    {
                        $0[.unset]
                        {
                            $0[Unidoc.Snapshot[.vintage]] = ()
                        }
                    }
                }
            }
        }
    }
}
extension Unidoc.DB.Snapshots
{
    /// Returns a single batch of symbol graphs that are queued for linking.
    public
    func pending(_ limit:Int) async throws -> [QueuedOperation]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<QueuedOperation>>.init(Self.name,
                limit: limit)
            {
                $0[.filter]
                {
                    $0[Unidoc.Snapshot[.action]] { $0[.exists] = true }
                }
                $0[.projection]
                {
                    $0[Unidoc.Snapshot[.action]] = true
                    $0[Unidoc.Snapshot[.type]] = true
                    $0[Unidoc.Snapshot[.size]] = true
                }

                $0[.hint] = Self.indexPendingActions.id
            },
            against: self.database)
    }

    /// Returns a single batch of the symbol graphs in the database with the oldest ABI
    /// versions.
    public
    func oldest(_ limit:Int,
        until version:PatchVersion) async throws -> [Unidoc.Edition]
    {
        let editions:[Mongo.IdentityDocument<Unidoc.Edition>] = try await session.run(
            command: Mongo.Find<
                Mongo.SingleBatch<Mongo.IdentityDocument<Unidoc.Edition>>>.init(Self.name,
                limit: limit)
            {
                $0[.filter]
                {
                    //  This needs to be ``BSON.Null`` and not just `{ $0[.exists] = false }`,
                    //  otherwise it will not use the partial index.
                    $0[Unidoc.Snapshot[.vintage]] = BSON.Null.init()
                    $0[Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]]
                    {
                        $0[.lt] = version
                    }
                }
                $0[.sort]
                {
                    $0[Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]] = (+)
                }

                $0[.projection]
                {
                    $0[Unidoc.Snapshot[.id]] = true
                }

                $0[.hint] = Self.indexSymbolGraphABI.id
            },
            against: self.database)

        return editions.map(\.id)
    }
}
