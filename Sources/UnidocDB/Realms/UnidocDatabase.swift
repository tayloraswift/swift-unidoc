import FNV1
import GitHubAPI
import MongoDB
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc
import UnidocLinker
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

    @inlinable public
    var sitemaps:Sitemaps { .init(database: self.id) }
    @inlinable public
    var packages:Packages { .init(database: self.id) }
    @inlinable public
    var editions:Editions { .init(database: self.id) }
    @inlinable public
    var graphs:Graphs { .init(database: self.id) }

    var meta:Meta { .init(database: self.id) }

    @inlinable public
    var volumes:Volumes { .init(database: self.id) }
    @inlinable public
    var vertices:Vertices { .init(database: self.id) }
    var groups:Groups { .init(database: self.id) }
    var search:Search { .init(database: self.id) }
    var trees:Trees { .init(database: self.id) }

    @inlinable public
    var repoFeed:RepoFeed { .init(database: self.id) }
    @inlinable public
    var docsFeed:DocsFeed { .init(database: self.id) }
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
        try await self.repoFeed.setup(with: session)
        try await self.docsFeed.setup(with: session)

        try await self.sitemaps.setup(with: session)
        try await self.packages.setup(with: session)
        try await self.editions.setup(with: session)
        try await self.graphs.setup(with: session)
        try await self.meta.setup(with: session)

        try await self.volumes.setup(with: session)
        try await self.vertices.setup(with: session)
        try await self.groups.setup(with: session)
        try await self.search.setup(with: session)
        try await self.trees.setup(with: session)
    }
}

@available(*, unavailable, message: "unused")
extension UnidocDatabase
{
    private
    func _clear(with session:Mongo.Session) async throws
    {
        try await self.volumes.replace(with: session)
        try await self.vertices.replace(with: session)
        try await self.groups.replace(with: session)
        try await self.search.replace(with: session)
        try await self.trees.replace(with: session)
        try await self.sitemaps.replace(with: session)
    }

    func _editions(of package:PackageIdentifier,
        with session:Mongo.Session) async throws -> [Realm.Edition]
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Realm.Edition>>.init(Packages.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[Realm.Package[.id]] = package
                        }
                    }

                    let editions:Mongo.KeyPath = "editions"

                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            $0[.from] = Editions.name
                            $0[.localField] = Realm.Package[.coordinate]
                            $0[.foreignField] = Realm.Edition[.package]
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
                                $0[let: cell] = Realm.Package[.coordinate]
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
extension UnidocDatabase
{
    @_spi(testable)
    public
    func track(package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Int32
    {
        try await self.packages.register(package,
            updating: self.meta,
            tracking: nil,
            with: session).coordinate
    }

    public
    func track(repo:GitHub.Repo, with session:Mongo.Session) async throws -> Int32
    {
        /// Currently, package identifiers are just the name of the repository.
        try await self.packages.register(.init(repo.name),
            updating: self.meta,
            tracking: .github(repo),
            with: session).coordinate
    }

    public
    func store(docs:SymbolGraphArchive,
        with session:Mongo.Session) async throws -> Uploaded
    {
        let package:Realm.Package = try await self.packages.register(docs.metadata.package,
            updating: self.meta,
            tracking: nil,
            with: session)

        let version:Int32

        if  let commit:SymbolGraphMetadata.Commit = docs.metadata.commit,
            let semver:SemanticVersion = .init(refname: commit.refname)
        {
            let placement:Editions.Placement = try await self.editions.register(
                package: package.coordinate,
                version: semver,
                refname: commit.refname,
                sha1: commit.hash,
                with: session)

            version = placement.coordinate
        }
        else if case .swift = docs.metadata.package,
            let tagname:String = docs.metadata.commit?.refname,
            let semver:SemanticVersion = .init(swiftRelease: tagname)
        {
            let placement:Editions.Placement = try await self.editions.register(
                package: package.coordinate,
                version: semver,
                refname: tagname,
                sha1: nil,
                with: session)

            version = placement.coordinate
        }
        else
        {
            version = -1
        }

        let snapshot:Snapshot = .init(
            package: package.coordinate,
            version: version,
            metadata: docs.metadata,
            graph: docs.graph)

        let upsert:Graphs.Upsert = try await self.graphs.upsert(snapshot,
            with: session)

        return .init(id: snapshot.id,
            edition: snapshot.edition,
            realm: package.realm,
            graph: upsert)
    }
}
extension UnidocDatabase
{
    public
    func publish(docs:SymbolGraphArchive,
        with session:Mongo.Session) async throws -> (Uploaded, Uplinked)
    {
        let uploaded:Uploaded = try await self.store(docs: docs, with: session)

        let volume:Volume = try await self.link(.init(
                package: uploaded.package,
                version: uploaded.version,
                metadata: docs.metadata,
                graph: docs.graph),
            realm: uploaded.realm,
            with: session)

        let uplinked:Uplinked = .init(
            edition: uploaded.edition,
            sitemap: try await self.fill(volume: consume volume,
                clear: uploaded.graph == .update,
                with: session))

        return (uploaded, uplinked)
    }

    public
    func uplink(
        package:Int32,
        version:Int32,
        with session:Mongo.Session) async throws -> Uplinked?
    {
        guard
        let record:Realm.Package = try await self.packages.find(by: package, with: session)
        else
        {
            return nil
        }

        var uplinked:Uplinked?

        try await self.graphs.list(
            filter: (package: package, version: version),
            with: session)
        {
            uplinked = .init(
                edition: $0.edition,
                sitemap: try await self.fill(volume: try await self.link($0,
                        realm: record.realm,
                        with: session),
                    clear: true,
                    with: session),
                visibleInFeed: record.repo?.visibleInFeed ?? true)
        }

        return uplinked
    }

    public
    func uplink(volume:VolumeIdentifier,
        with session:Mongo.Session) async throws -> Uplinked?
    {
        if  let volume:Volume.Meta = try await self.volumes.find(named: volume,
                with: session)
        {
            try await self.uplink(
                package: volume.id.package,
                version: volume.id.version,
                with: session)
        }
        else
        {
            nil
        }
    }

    @discardableResult
    public
    func unlink(volume:VolumeIdentifier,
        with session:Mongo.Session) async throws -> Unidoc.Edition?
    {
        if  let volume:Volume.Meta = try await self.volumes.find(named: volume,
                with: session)
        {
            try await self.vertices.clear(volume.id, with: session)
            try await self.groups.clear(volume.id, with: session)
            try await self.trees.clear(volume.id, with: session)

            try await self.search.delete(volume.symbol, with: session)
            //  Delete this last, otherwise if one of the other steps fails, we won’t
            //  have an easy way to clean up the remaining documents.
            try await self.volumes.delete(volume.id, with: session)

            return volume.id
        }
        else
        {
            return nil
        }
    }
}
extension UnidocDatabase
{
    private
    func fill(volume:consuming Volume,
        clear:Bool = true,
        with session:Mongo.Session) async throws -> Realm.Sitemap.Delta?
    {
        if  clear
        {
            try await self.vertices.clear(volume.edition, with: session)
            try await self.groups.clear(volume.edition, with: session)
            try await self.trees.clear(volume.edition, with: session)

            try await self.search.delete(volume.id, with: session)
            try await self.volumes.delete(volume.edition, with: session)
        }
        //  If there is a volume generated from a prerelease with the same patch number,
        //  we need to delete that too.
        try await self.unlink(volume: volume.id, with: session)

        try await self.volumes.insert(some: volume.meta, with: session)
        try await self.vertices.insert(some: volume.vertices, with: session)
        try await self.trees.insert(some: volume.trees, with: session)
        try await self.search.insert(some: volume.search, with: session)

        let delta:Realm.Sitemap.Delta?

        if  volume.meta.latest
        {
            delta = try await self.sitemaps.update(volume.sitemap(), with: session)
            try await self.groups.insert(some: volume.groups(latest: true), with: session)
        }
        else
        {
            delta = nil
            try await self.groups.insert(some: volume.groups, with: session)
        }
        if  let latest:Unidoc.Edition = volume.latest
        {
            try await self.volumes.align(latest: latest, with: session)
            try await self.groups.align(latest: latest, with: session)
        }

        return delta
    }

    private
    func link(_ snapshot:Snapshot,
        realm:Realm,
        with session:Mongo.Session) async throws -> Volume
    {
        let context:DynamicContext = .init(snapshot,
            dependencies: try await self.graphs.load(snapshot.metadata.pins(),
                with: session))

        let dependencies:[Volume.Meta.Dependency] = context.dependencies()
        let symbolicator:DynamicSymbolicator = .init(context: context,
            root: snapshot.metadata.root)
        let linker:DynamicLinker = .init(context: consume context)

        (consume symbolicator).symbolicate(printing: linker.diagnostics, colors: .enabled)

        let id:Snapshot.ID = snapshot.id

        let formerRelease:Volumes.PatchView? = try await self.volumes.latestRelease(
            of: snapshot.package,
            with: session)

        let latestRelease:Unidoc.Edition?
        let thisRelease:PatchVersion?

        switch id.version.canonical
        {
        case .stable(.release(let patch, build: _)):
            if  let formerRelease:Volumes.PatchView,
                    formerRelease.patch > patch
            {
                latestRelease = formerRelease.id
            }
            else
            {
                latestRelease = snapshot.edition
            }

            thisRelease = patch

        case _:
            latestRelease = formerRelease?.id
            thisRelease = nil
        }

        let mesh:DynamicLinker.Mesh = linker.link()

        let meta:Volume.Meta = .init(id: snapshot.edition,
            dependencies: dependencies,
            display: snapshot.metadata.display,
            refname: snapshot.metadata.commit?.refname,
            commit: snapshot.metadata.commit?.hash,
            symbol: id.volume,
            latest: snapshot.edition == latestRelease,
            realm: realm,
            patch: thisRelease,
            link: mesh.meta,
            tree: mesh.tree)

        let volume:Volume = .init(latest: latestRelease,
            vertices: mesh.vertices,
            groups: mesh.groups,
            index: mesh.index,
            trees: mesh.trees,
            meta: meta)

        return volume
    }
}
