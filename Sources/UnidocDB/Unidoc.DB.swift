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
@_spi(testable)
import UnidocRecords

@available(*, deprecated, renamed: "Unidoc.DB")
public
typealias UnidocDatabase = Unidoc.DB

extension Unidoc
{
    @frozen public
    struct DB:Identifiable, Sendable
    {
        public
        let id:Mongo.Database

        @inlinable public
        init(id:Mongo.Database)
        {
            self.id = id
        }
    }
}
extension Unidoc.DB
{
    var policies:Policies { .init() }

    @inlinable public
    var crawlingWindows:CrawlingWindows { .init(database: self.id) }
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
    @inlinable public
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
extension Unidoc.DB:Mongo.DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.crawlingWindows.setup(with: session)
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

extension Unidoc.DB
{
    /// Registers an **alias** of a package realm.
    public
    func index(realm:String,
        with session:Mongo.Session) async throws -> (realm:Unidoc.RealmMetadata, new:Bool)
    {
        let autoincrement:Unidoc.Autoincrement<Unidoc.RealmMetadata> = try await session.query(
            database: self.id,
            with: Unidoc.AutoincrementQuery<RealmAliases, Realms>.init(symbol: realm))
            ?? .first

        switch consume autoincrement
        {
        case .new(let id):
            //  This can fail if we race with another process.
            try await self.realmAliases.insert(alias: realm, of: id, with: session)
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
    @_spi(testable)
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
        let _:Never? = try await session.query(database: self.id, with: query)
    }

    public
    func index(package:Symbol.Package,
        repo:Unidoc.PackageRepo? = nil,
        mode:Unidoc.PackageIndexMode = .manual,
        with session:Mongo.Session) async throws -> (package:Unidoc.PackageMetadata, new:Bool)
    {
        if  let repo:Unidoc.PackageRepo = repo,
            case .github(let origin) = repo.origin,
            var existing:Unidoc.PackageMetadata = try await self.packages.findGitHub(
                repo: origin.id,
                with: session)
        {
            //  According to GitHub, this package is already known to us by a different name.
            aliasing:
            do
            {
                if  existing.symbol == package
                {
                    break aliasing
                }

                try await self.packageAliases.insert(alias: package,
                    of: existing.id,
                    with: session)
            }
            catch is Mongo.WriteError
            {
                //  Alias already exists.
            }

            existing.crawled(repo: consume repo)

            try await self.packages.update(package: existing.id,
                repo: existing.repo,
                with: session)

            return (existing, false)
        }

        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Unidoc.Autoincrement<Unidoc.PackageMetadata> = try await session.query(
            database: self.id,
            with: Unidoc.AutoincrementQuery<PackageAliases, Packages>.init(symbol: package))
            ?? .first

        switch consume placement
        {
        case .new(let id):
            try await self.packageAliases.insert(alias: package, of: id, with: session)
            fallthrough

        case .old(let id, nil):
            var package:Unidoc.PackageMetadata = .init(id: id,
                symbol: package,
                hidden: mode == .automatic,
                realm: nil)

            if  let repo:Unidoc.PackageRepo = repo
            {
                package.crawled(repo: consume repo)
            }

            try await self.packages.insert(some: package, with: session)

            if !package.hidden
            {
                try await self.rebuildPackageList(with: session)
            }

            return (package, true)

        case .old(_, var package?):
            if  let repo:Unidoc.PackageRepo
            {
                package.crawled(repo: consume repo)

                try await self.packages.update(package: package.id,
                    repo: package.repo,
                    with: session)
            }

            return (package, false)
        }
    }

    /// Registers an **edition** of a package.
    public
    func index(
        package:Unidoc.Package,
        version:SemanticVersion,
        name:String,
        sha1:SHA1?,
        with session:Mongo.Session) async throws -> (edition:Unidoc.EditionMetadata, new:Bool)
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Unidoc.EditionPlacement = try await session.query(
            database: self.id,
            with: Unidoc.EditionPlacementQuery.init(package: package, refname: name))
            ?? .first

        switch consume placement
        {
        case .new(let id):
            let edition:Unidoc.EditionMetadata = .init(id: .init(
                    package: package,
                    version: id),
                release: version.release,
                patch: version.patch,
                name: name,
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
extension Unidoc.DB
{
    /// Indexes and stores a symbol graph in the database, linking it **synchronously**.
    @_spi(testable)
    public
    func store(linking docs:SymbolGraphObject<Void>,
        with session:Mongo.Session) async throws -> (Unidoc.UploadStatus, Unidoc.UplinkStatus)
    {
        var snapshot:Unidoc.Snapshot
        let realm:Unidoc.Realm?

        //  Don’t queue for uplink, since we’re going to do that synchronously.
        (snapshot, realm) = try await self.label(docs: docs, link: nil, with: session)

        enum NoLoader:Unidoc.GraphLoader
        {
            func load(graph:Unidoc.GraphPath) async throws -> ArraySlice<UInt8>
            {
                throw Unidoc.GraphLoaderError.unavailable
            }
        }

        let volume:Unidoc.Volume = try await self.link(&snapshot,
            symbol: docs.metadata.package.id,
            loader: nil as NoLoader?,
            realm: realm,
            with: session)
        let symbol:Symbol.Edition = volume.metadata.symbol

        let uploaded:Unidoc.UploadStatus = try await self.snapshots.upsert(
            snapshot: consume snapshot,
            with: session)

        let uplinked:Unidoc.UplinkStatus = .init(
            edition: uploaded.edition,
            volume: symbol,
            hidden: true,
            delta: try await self.fill(volume: consume volume,
                clear: uploaded.updated,
                with: session))

        return (uploaded, uplinked)
    }

    /// Indexes and stores a symbol graph in the database, queueing it for an **asynchronous**
    /// uplink.
    public
    func store(docs:consuming SymbolGraphObject<Void>,
        with session:Mongo.Session) async throws -> Unidoc.UploadStatus
    {
        let (snapshot, _):(Unidoc.Snapshot, Unidoc.Realm?) = try await self.label(docs: docs,
            link: .initial,
            with: session)

        return try await self.snapshots.upsert(snapshot: snapshot, with: session)
    }

    private
    func label(docs:consuming SymbolGraphObject<Void>,
        link:Unidoc.Snapshot.LinkState?,
        with session:Mongo.Session) async throws ->
        (
            snapshot:Unidoc.Snapshot,
            realm:Unidoc.Realm?
        )
    {
        let docs:SymbolGraphObject<Void> = docs
        let (package, _):(Unidoc.PackageMetadata, Bool) = try await self.index(
            package: docs.metadata.package.id,
            repo: nil,
            with: session)

        //  Is this a version-controlled package?
        let version:Unidoc.Version
        if  let commit:SymbolGraphMetadata.Commit = docs.metadata.commit,
            let semver:SemanticVersion = docs.metadata.package.name.version(tag: commit.name)
        {
            let (edition, _):(Unidoc.EditionMetadata, Bool) = try await self.index(
                package: package.id,
                version: semver,
                name: commit.name,
                sha1: commit.sha1,
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
            inline: docs.graph,
            link: link)

        return (snapshot, package.realm)
    }
}
extension Unidoc.DB
{
    public
    func uplink(_ id:Unidoc.Edition,
        loader:(some Unidoc.GraphLoader)?,
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

        /// We do **not** transition the snapshot link state here, since we would rather
        /// update the field selectively, and do so **after** we have successfully filled the
        /// volume.
        var snapshot:Unidoc.Snapshot = stored

        let hidden:Bool = package.hidden || snapshot.link != .initial
        let volume:Unidoc.Volume = try await self.link(&snapshot,
            symbol: package.symbol,
            loader: loader,
            realm: package.realm,
            with: session)
        let symbol:Symbol.Edition = volume.metadata.symbol

        if  stored != snapshot
        {
            try await self.snapshots.update(some: snapshot, with: session)
        }

        return .init(
            edition: id,
            volume: symbol,
            hidden: hidden,
            delta: try await self.fill(volume: consume volume,
                clear: true,
                with: session))
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
extension Unidoc.DB
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
            try await session.update(database: self.id,
                with: Volumes.AlignLatest.init(to: latest))

            guard
            let realm:Unidoc.Realm = volume.metadata.realm
            else
            {
                break alignment
            }

            try await session.update(database: self.id,
                with: Groups.AlignLatest.init(to: latest, in: realm))
        }

        return delta
    }

    private
    func pin(_ snapshot:inout Unidoc.Snapshot,
        with session:Mongo.Session) async throws -> [Unidoc.Edition]
    {
        print("pinning dependencies for \(snapshot.metadata.package.name)...")

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

        for dependency:Symbol.PackageDependency<Unidoc.Edition> in try await session.query(
            database: self.id,
            with: query)
        {
            pins[dependency.package] = dependency.version
        }

        var all:[Unidoc.Edition] = []

        for (pin, dependency):(Int, SymbolGraphMetadata.Dependency) in zip(
            snapshot.pins.indices,
            snapshot.metadata.dependencies)
        {
            if  let pinned:Unidoc.Edition = pins[dependency.id]
            {
                snapshot.pins[pin] = pinned
                all.append(pinned)
            }
            else if
                let pinned:Unidoc.Edition = snapshot.pins[pin]
            {
                all.append(pinned)
            }
            else
            {
                print("failed to pin '\(dependency.id)' to '\(dependency.version)'")
            }
        }

        return all
    }

    private
    func link(_ snapshot:inout Unidoc.Snapshot,
        symbol package:Symbol.Package,
        loader:(some Unidoc.GraphLoader)?,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws -> Unidoc.Volume
    {
        let pins:[Unidoc.Edition] = try await self.pin(&snapshot, with: session)
        var linker:Unidoc.Linker = try await self.snapshots.load(for: snapshot,
            from: loader,
            pins: pins,
            with: session)

        let dependencies:[Unidoc.VolumeMetadata.Dependency] = linker.dependencies()
        let mesh:Unidoc.Linker.Mesh = linker.link()

        linker.status().emit(colors: .enabled)

        let latestRelease:Unidoc.Edition?
        let thisRelease:PatchVersion?
        let version:String

        if  let commit:SymbolGraphMetadata.Commit = snapshot.metadata.commit
        {
            let formerRelease:Volumes.PatchView? = try await self.volumes.latestRelease(
                of: snapshot.id.package,
                with: session)

            switch snapshot.metadata.package.name.version(tag: commit.name)
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
            refname: snapshot.metadata.commit?.name,
            symbol: .init(
                //  We want the version component of the volume symbol to be stable,
                //  so we only encode the patch version, even if the symbol graph is
                //  from a prerelease tag.
                package: package,
                version: version),
            latest: snapshot.id == latestRelease,
            realm: realm,
            patch: thisRelease,
            products: mesh.products,
            cultures: mesh.cultures)

        let volume:Unidoc.Volume = .init(latest: latestRelease,
            metadata: metadata,
            vertices: mesh.vertices,
            groups: mesh.groups,
            index: mesh.index,
            trees: mesh.trees)

        return volume
    }
}
extension Unidoc.DB
{
    //  Regenerates the JSON list of all packages.
    public
    func rebuildPackageList(with session:Mongo.Session) async throws
    {
        let index:Unidoc.TextResource<Unidoc.DB.Metadata.Key> = try await self.packages.scan(
            with: session)
        try await self.metadata.upsert(some: index, with: session)
    }

    public
    func align(
        package:Unidoc.Package,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws
    {
        try await session.update(database: self.id,
            with: Unidoc.DB.Packages.AlignRealm.aligning(package))

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

            try await session.update(database: self.id,
                with: Groups.AlignLatest.init(to: latest.id, in: realm))
        }
        else
        {
            try await session.update(database: self.id,
                with: Groups.ClearLatest.init(from: package))
        }

        try await session.update(database: self.id,
            with: Volumes.AlignRealm.init(range: .package(package), to: realm))

        try await session.update(database: self.id,
            with: Unidoc.DB.Packages.AlignRealm.aligned(package, to: realm))
    }
}
