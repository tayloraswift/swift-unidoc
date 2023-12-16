import FNV1
import GitHubAPI
import MongoDB
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI
import UnidocDiagnostics
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
    var repoFeed:RepoFeed { .init(database: self.id) }
    @inlinable public
    var docsFeed:DocsFeed { .init(database: self.id) }

    @inlinable public
    var realmAliases:RealmAliases { .init(database: self.id) }
    @inlinable public
    var realms:Realms { .init(database: self.id) }
    @inlinable public
    var packageAliases:PackageAliases { .init(database: self.id) }
    @inlinable public
    var packages:Packages { .init(database: self.id) }
    @inlinable public
    var editions:Editions { .init(database: self.id) }
    @inlinable public
    var snapshots:Snapshots { .init(database: self.id) }
    @inlinable public
    var sitemaps:Sitemaps { .init(database: self.id) }
    var metadata:Metadata { .init(database: self.id) }

    @inlinable public
    var volumes:Volumes { .init(database: self.id) }
    @inlinable public
    var vertices:Vertices { .init(database: self.id) }
    var groups:Groups { .init(database: self.id) }
    var search:Search { .init(database: self.id) }
    var trees:Trees { .init(database: self.id) }

    @inlinable public
    var users:Users { .init(database: self.id) }
}
extension UnidocDatabase:Mongo.DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.repoFeed.setup(with: session)
        try await self.docsFeed.setup(with: session)

        try await self.realmAliases.setup(with: session)
        try await self.realms.setup(with: session)
        try await self.packageAliases.setup(with: session)
        try await self.packages.setup(with: session)
        try await self.editions.setup(with: session)
        try await self.snapshots.setup(with: session)
        try await self.sitemaps.setup(with: session)
        try await self.metadata.setup(with: session)

        try await self.volumes.setup(with: session)
        try await self.vertices.setup(with: session)
        try await self.groups.setup(with: session)
        try await self.search.setup(with: session)
        try await self.trees.setup(with: session)

        try await self.users.setup(with: session)
    }
}

extension UnidocDatabase
{
    /// Registers an **alias** of a package realm.
    public
    func index(realm:String,
        with session:Mongo.Session) async throws -> (realm:Unidoc.RealmMetadata, new:Bool)
    {
        let autoincrement:Unidoc.Autoincrement<Unidoc.RealmMetadata> = try await self.execute(
            query: Unidoc.AutoincrementQuery<RealmAliases, Realms>.init(symbol: realm),
            with: session) ?? .first

        switch consume autoincrement
        {
        case .new(let id):
            let realm:Unidoc.RealmAlias = .init(id: realm, coordinate: id)
            //  This can fail if we race with another process.
            try await self.realmAliases.insert(some: realm, with: session)
            fallthrough

        case .old(let id, nil):
            //  Edge case: the most likely reason for this is that we successfully inserted
            //  the ``Unidoc.RealmAlias`` document, but failed to insert the
            //  ``Unidoc.RealmMetadata`` document.
            let realm:Unidoc.RealmMetadata = .init(id: id, symbol: realm)
            try await self.realms.insert(some: realm, with: session)
            return (realm, true)

        case .old(_, let realm?):
            return (realm, false)
        }
    }

    /// Registers an **alias** of a package.
    public
    func alias(
        existing package:Symbol.Package,
        package alias:Symbol.Package,
        with session:Mongo.Session) async throws
    {
        guard
        let query:Unidoc.AliasQuery<PackageAliases> = .init(symbol: package, alias: alias)
        else
        {
            //  Symbols are the same.
            return
        }
        let _:Never? = try await self.execute(query: query, with: session)
    }

    public
    func index(package:Symbol.Package,
        repo:consuming Unidoc.PackageMetadata.Repo? = nil,
        with session:Mongo.Session) async throws -> (package:Unidoc.PackageMetadata, new:Bool)
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let autoincrement:Unidoc.Autoincrement<Unidoc.PackageMetadata> = try await self.execute(
            query: Unidoc.AutoincrementQuery<PackageAliases, Packages>.init(symbol: package),
            with: session) ?? .first

        switch consume autoincrement
        {
        case .new(let id):
            let package:Unidoc.PackageAlias = .init(id: package, coordinate: id)
            try await self.packageAliases.insert(some: package, with: session)
            fallthrough

        case .old(let id, nil):
            let package:Unidoc.PackageMetadata = .init(id: id,
                symbol: package,
                realm: nil,
                repo: repo)

            try await self.packages.insert(some: package, with: session)

            //  Regenerate the JSON list of all packages.
            let index:SearchIndex<Int32> = try await self.packages.scan(with: session)

            try await self.metadata.upsert(some: index, with: session)

            return (package, true)

        case .old(_, var package?):
            if  let repo:Unidoc.PackageMetadata.Repo,
                    repo != package.repo
            {
                package.repo = repo
                try await self.packages.update(some: package, with: session)
            }

            return (package, false)
        }
    }

    /// Registers an **edition** of a package.
    public
    func register(
        package:Unidoc.Package,
        version:SemanticVersion,
        refname:String,
        sha1:SHA1?,
        with session:Mongo.Session) async throws -> (edition:Unidoc.EditionMetadata, new:Bool)
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Unidoc.EditionPlacement = try await self.execute(
            query: Unidoc.EditionPlacementQuery.init(
                package: package,
                refname: refname),
            with: session) ?? .first

        switch consume placement
        {
        case .new(let id):
            let edition:Unidoc.EditionMetadata = .init(id: .init(
                    package: package,
                    version: id),
                release: version.release,
                patch: version.patch,
                name: refname,
                sha1: sha1)
            //  This can fail if we race with another process.
            try await self.editions.insert(some: edition, with: session)

            return (edition, true)

        case .old(var edition):
            if  let sha1:SHA1,
                    sha1 != edition.sha1
            {
                edition.sha1 = sha1
                try await self.editions.update(some: edition, with: session)
            }

            return (edition, false)
        }
    }
}
extension UnidocDatabase
{
    public
    func store(docs:consuming SymbolGraphArchive,
        with session:Mongo.Session) async throws -> Unidoc.UploadStatus
    {
        let (snapshot, _):(Unidoc.Snapshot, Unidoc.Realm?) = try await self.label(docs: docs,
            with: session)

        return try await self.snapshots.upsert(snapshot: snapshot, with: session)
    }

    private
    func label(docs:consuming SymbolGraphArchive,
        with session:Mongo.Session) async throws ->
        (
            snapshot:Unidoc.Snapshot,
            realm:Unidoc.Realm?
        )
    {
        let docs:SymbolGraphArchive = docs
        let (package, _):(Unidoc.PackageMetadata, Bool) = try await self.index(
            package: docs.metadata.package,
            repo: nil,
            with: session)

        //  Is this a version-controlled package?
        let version:Unidoc.Version
        if  let commit:SymbolGraphMetadata.Commit = docs.metadata.commit,
            let semver:SemanticVersion = docs.metadata.package.version(tag: commit.refname)
        {
            let (edition, _):(Unidoc.EditionMetadata, Bool) = try await self.register(
                package: package.id,
                version: semver,
                refname: commit.refname,
                sha1: commit.hash,
                with: session)

            version = edition.version
        }
        else
        {
            version = -1
        }

        let snapshot:Unidoc.Snapshot = .init(id: .init(
                package: package.id,
                version: version),
            metadata: docs.metadata,
            graph: docs.graph)

        return (snapshot, package.realm)
    }
}
extension UnidocDatabase
{
    public
    func publish(docs:SymbolGraphArchive,
        with session:Mongo.Session) async throws -> (Unidoc.UploadStatus, Unidoc.UplinkStatus)
    {
        var snapshot:Unidoc.Snapshot
        let realm:Unidoc.Realm?

        (snapshot, realm) = try await self.label(docs: docs, with: session)

        let volume:Unidoc.Volume = try await self.link(&snapshot,
            realm: realm,
            with: session)

        let uploaded:Unidoc.UploadStatus = try await self.snapshots.upsert(
            snapshot: consume snapshot,
            with: session)

        let uplinked:Unidoc.UplinkStatus = .init(
            edition: uploaded.edition,
            sitemap: try await self.fill(volume: consume volume,
                clear: uploaded.updated,
                with: session))

        return (uploaded, uplinked)
    }

    public
    func uplink(_ id:Unidoc.Edition,
        with session:Mongo.Session) async throws -> Unidoc.UplinkStatus?
    {
        guard
        let package:Unidoc.PackageMetadata = try await self.packages.find(id: id.package,
            with: session),
        let stored:Unidoc.Snapshot = try await self.snapshots.find(id: id,
            with: session)
        else
        {
            return nil
        }

        var snapshot:Unidoc.Snapshot = stored

        let volume:Unidoc.Volume = try await self.link(&snapshot,
            realm: package.realm,
            with: session)

        if  stored != snapshot
        {
            try await self.snapshots.update(some: snapshot, with: session)
        }

        return .init(
            edition: id,
            sitemap: try await self.fill(volume: consume volume,
                clear: true,
                with: session),
            visibleInFeed: package.repo?.visibleInFeed ?? true)
    }

    public
    func uplink(volume:Symbol.Edition,
        with session:Mongo.Session) async throws -> Unidoc.UplinkStatus?
    {
        if  let volume:Unidoc.VolumeMetadata = try await self.volumes.find(named: volume,
                with: session)
        {
            try await self.uplink(volume.id, with: session)
        }
        else
        {
            nil
        }
    }

    public
    func unlink(volume:Symbol.Edition,
        with session:Mongo.Session) async throws -> Unidoc.UnlinkStatus?
    {
        guard
        let volume:Unidoc.VolumeMetadata = try await self.volumes.find(named: volume,
            with: session)
        else
        {
            return nil
        }

        if  case nil = volume.patch
        {
            try await self.vertices.clear(range: volume.id, with: session)
            try await self.groups.clear(range: volume.id, with: session)
            try await self.trees.clear(range: volume.id, with: session)

            try await self.search.delete(id: volume.symbol, with: session)
            //  Delete this last, otherwise if one of the other steps fails, we won’t
            //  have an easy way to clean up the remaining documents.
            try await self.volumes.delete(id: volume.id, with: session)

            return .unlinked(volume.id)
        }
        else
        {
            return .declined(volume.id)
        }
    }
}
extension UnidocDatabase
{
    private
    func fill(volume:consuming Unidoc.Volume,
        clear:Bool = true,
        with session:Mongo.Session) async throws -> Unidoc.SitemapDelta?
    {
        if  clear
        {
            try await self.vertices.clear(range: volume.edition, with: session)
            try await self.groups.clear(range: volume.edition, with: session)
            try await self.trees.clear(range: volume.edition, with: session)

            try await self.search.delete(id: volume.id, with: session)
            try await self.volumes.delete(id: volume.edition, with: session)
        }
        //  If there is a volume generated from a prerelease with the same patch number,
        //  we need to delete that too.
        if  case .declined? = try await self.unlink(volume: volume.id, with: session)
        {
            //  We should not clear release versions by name, only by coordinate.
            return nil
        }

        try await self.volumes.insert(some: volume.metadata, with: session)
        try await self.search.insert(some: volume.search, with: session)
        try await self.trees.insert(some: volume.trees, with: session)

        try await self.vertices.insert(volume.vertices, with: session)
        try await self.groups.insert(volume.groups,
            realm: volume.metadata.latest ? volume.metadata.realm : nil,
            with: session)

        let delta:Unidoc.SitemapDelta? = volume.metadata.latest
            ? try await self.sitemaps.update(volume.sitemap(), with: session)
            : nil

        alignment:
        if  let latest:Unidoc.Edition = volume.latest
        {
            try await self.execute(
                update: Volumes.AlignLatest.init(to: latest),
                with: session)

            guard
            let realm:Unidoc.Realm = volume.metadata.realm
            else
            {
                break alignment
            }

            try await self.execute(
                update: Groups.AlignLatest.init(to: latest, in: realm),
                with: session)
        }

        return delta
    }

    private
    func pin(_ snapshot:inout Unidoc.Snapshot,
        with session:Mongo.Session) async throws -> [Unidoc.Edition]
    {
        print("pinning dependencies for \(snapshot.metadata.package)...")

        //  Important: all snapshots start off with an empty pin list, so we might need to
        //  extend the array to match the number of dependencies in the metadata.
        let unallocated:Int = snapshot.metadata.dependencies.count - snapshot.pins.count
        if  unallocated > 0
        {
            snapshot.pins += repeatElement(nil, count: unallocated)
        }

        guard
        let query:Unidoc.PinDependenciesQuery = .init(for: snapshot)
        else
        {
            return snapshot.pins.compactMap { $0 }
        }

        var pins:[Symbol.Package: Unidoc.Edition] = [:]

        for pinned:Symbol.PackageDependency<Unidoc.Edition> in try await self.execute(
            query: consume query,
            with: session)
        {
            pins[pinned.package] = pinned.version
        }

        var all:[Unidoc.Edition] = []

        for (pin, dependency):(Int, SymbolGraphMetadata.Dependency) in zip(
            snapshot.pins.indices,
            snapshot.metadata.dependencies)
        {
            if  let pinned:Unidoc.Edition = pins[dependency.package]
            {
                snapshot.pins[pin] = pinned
                all.append(pinned)
            }
            else if
                let pinned:Unidoc.Edition = snapshot.pins[pin]
            {
                all.append(pinned)
            }
        }

        return all
    }

    private
    func link(_ snapshot:inout Unidoc.Snapshot,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws -> Unidoc.Volume
    {
        let pins:[Unidoc.Edition] = try await self.pin(&snapshot, with: session)
        var linker:DynamicLinker = try await self.snapshots.load(for: snapshot,
            pins: pins,
            with: session)

        let dependencies:[Unidoc.VolumeMetadata.Dependency] = linker.dependencies()
        let mesh:DynamicLinker.Mesh = linker.link()

        linker.status().emit(colors: .enabled)

        let latestRelease:Unidoc.Edition?
        let thisRelease:PatchVersion?
        let version:String

        if  let commit:SymbolGraphMetadata.Commit = snapshot.metadata.commit
        {
            let formerRelease:Volumes.PatchView? = try await self.volumes.latestRelease(
                of: snapshot.id.package,
                with: session)

            switch snapshot.metadata.package.version(tag: commit.refname)
            {
            case .release(let patch, build: _)?:
                if  let formerRelease:Volumes.PatchView,
                        formerRelease.patch > patch
                {
                    latestRelease = formerRelease.id
                }
                else
                {
                    latestRelease = snapshot.id
                }

                thisRelease = patch
                version = "\(patch)"

            case .prerelease(let patch, _, build: _)?:
                latestRelease = formerRelease?.id
                thisRelease = nil
                version = "\(patch)"

            case nil:
                latestRelease = formerRelease?.id
                thisRelease = nil
                version = "0.0.0"
            }
        }
        else
        {
            //  Local packages are always considered release versions.
            latestRelease = snapshot.id
            thisRelease = .max
            version = "__max"
        }

        let metadata:Unidoc.VolumeMetadata = .init(id: snapshot.id,
            dependencies: dependencies,
            display: snapshot.metadata.display,
            refname: snapshot.metadata.commit?.refname,
            symbol: .init(
                //  We want the version component of the volume symbol to be stable,
                //  so we only encode the patch version, even if the symbol graph is
                //  from a prerelease tag.
                package: snapshot.metadata.package,
                version: version),
            latest: snapshot.id == latestRelease,
            realm: realm,
            patch: thisRelease,
            tree: mesh.tree)

        let volume:Unidoc.Volume = .init(latest: latestRelease,
            metadata: metadata,
            vertices: mesh.vertices,
            groups: mesh.groups,
            index: mesh.index,
            trees: mesh.trees)

        return volume
    }
}
extension UnidocDatabase
{
    public
    func rebuild(queue:Bool = false, with session:Mongo.Session) async throws
    {
        if  queue
        {
            try await self.execute(update: Snapshots.QueueUplink.all, with: session)
        }
        while
            let editions:[Unidoc.Edition] = try await self.snapshots.linkable(8,
                with: session)
        {
            for edition:Unidoc.Edition in editions
            {
                async
                let cooldown:Void = Task.sleep(for: .seconds(5))

                guard
                let status:Unidoc.UplinkStatus = try await self.uplink(edition, with: session)
                else
                {
                    print("failed to uplink \(edition): volume not found")
                    continue
                }

                try await self.execute(
                    update: Snapshots.ClearUplink.one(edition),
                    with: session)

                if  let sitemap:Unidoc.SitemapDelta = status.sitemap
                {
                    print("""
                        successfully uplinked \(edition): \
                        sitemap gained \(sitemap.additions) pages, \
                        lost \(sitemap.deletions.count) pages
                        """)
                }
                else
                {
                    print("successfully uplinked \(edition)")
                }


                try await cooldown
            }
        }
    }

    public
    func align(
        package:Unidoc.Package,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws
    {
        try await self.execute(
            update: UnidocDatabase.Packages.AlignRealm.aligning(package),
            with: session)

        groups:
        if  let realm:Unidoc.Realm
        {
            guard
            let latest:Volumes.PatchView = try await self.volumes.latestRelease(of: package,
                with: session)
            else
            {
                break groups
            }

            try await self.execute(
                update: Groups.AlignLatest.init(to: latest.id, in: realm),
                with: session)
        }
        else
        {
            try await self.execute(
                update: Groups.ClearLatest.init(from: package),
                with: session)
        }

        try await self.execute(
            update: Volumes.AlignRealm.init(range: .package(package), to: realm),
            with: session)

        try await self.execute(
            update: UnidocDatabase.Packages.AlignRealm.aligned(package, to: realm),
            with: session)
    }
}
