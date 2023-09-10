import GitHubIntegration
import ModuleGraphs
import MongoDB
import SymbolGraphs
import UnidocAnalysis
import UnidocLinker

@frozen public
struct PackageDatabase:Identifiable, Sendable
{
    public
    let id:Mongo.Database

    @inlinable public
    init(id:Mongo.Database)
    {
        self.id = id
    }
}
extension PackageDatabase
{
    @inlinable public
    var packages:Packages { .init(database: self.id) }
    @inlinable public
    var editions:Editions { .init(database: self.id) }
    @inlinable public
    var graphs:Graphs { .init(database: self.id) }

    var meta:Meta { .init(database: self.id) }

    public static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }
}
extension PackageDatabase:DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.packages.setup(with: session)
        try await self.editions.setup(with: session)
        try await self.graphs.setup(with: session)
        try await self.meta.setup(with: session)
    }
}
extension PackageDatabase
{
    public
    func track(repo:GitHubAPI.Repo, with session:Mongo.Session) async throws -> Int32
    {
        /// Currently, package identifiers are just the name of the repository.
        try await self.packages.register(.init(repo.name),
            updating: self.meta,
            tracking: .github(repo),
            with: session).cell
    }

    public
    func store(docs:SymbolGraphArchive,
        with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        let placement:Packages.Placement = try await self.packages.register(
            docs.metadata.package,
            updating: nil,
            tracking: nil,
            with: session)

        let version:Int32

        if  let commit:SymbolGraphMetadata.Commit = docs.metadata.commit
        {
            let placement:Editions.Placement = try await self.editions.register(
                package: placement.cell,
                refname: commit.refname,
                sha1: commit.hash,
                with: session)

            version = placement.cell
        }
        else if case .swift = docs.metadata.package,
            let tagname:String = docs.metadata.commit?.refname
        {
            let placement:Editions.Placement = try await self.editions.register(
                package: placement.cell,
                refname: tagname,
                sha1: nil,
                with: session)

            version = placement.cell
        }
        else
        {
            version = -1
        }

        let snapshot:Snapshot = .init(
            package: placement.cell,
            version: version,
            metadata: docs.metadata,
            graph: docs.graph)

        let upsert:SnapshotReceipt.Upsert

        switch try await self.graphs.upsert(snapshot, with: session)
        {
        case nil:   upsert = .update
        case _?:    upsert = .insert
        }

        return .init(id: snapshot.id,
            edition: snapshot.edition,
            type: upsert,
            repo: placement.repo)
    }
}
extension PackageDatabase
{
    public
    func editions(of package:PackageIdentifier,
        with session:Mongo.Session) async throws -> [PackageEdition]
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<PackageEdition>>.init(Packages.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[PackageRecord[.id]] = package
                        }
                    }

                    let editions:Mongo.KeyPath = "editions"

                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            $0[.from] = Editions.name
                            $0[.localField] = PackageRecord[.cell]
                            $0[.foreignField] = PackageEdition[.package]
                            $0[.as] = editions
                        }
                    }

                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            let cell:Mongo.Variable<Int32> = "cell"

                            $0[.from] = Graphs.name
                            $0[.let] = .init
                            {
                                $0[let: cell] = PackageRecord[.cell]
                            }
                            $0[.pipeline] = .init
                            {
                                $0.stage
                                {
                                    $0[.match] = .init
                                    {
                                        $0[.expr] = .expr
                                        {
                                            $0[.eq] = (Snapshot[.package], cell)
                                        }
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
                                    $0[.limit] = 1
                                }

                                $0.stage
                                {
                                    $0[.replaceWith] = Snapshot[.metadata]
                                }
                            }
                            $0[.as] = "recent"
                        }
                    }

                    $0.stage
                    {
                        $0[.unwind] = editions
                    }

                    $0.stage
                    {
                        $0[.replaceWith] = editions
                    }
                },
                stride: 1),
            against: self.id)
        {
            try await $0.reduce(into: [], += )
        }
    }
}
