import BSON
import FNV1
import GitHubAPI
import MongoDB
import SemanticVersions
import SHA1
import SourceDiagnostics
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI
import UnidocRecords_LZ77
import UnidocLinker
@_spi(testable)
import UnidocRecords
import UnixTime

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
    var packageBuilds:PackageBuilds { .init(database: self.id) }
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
    var packageDependencies:PackageDependencies { .init(database: self.id) }
    @inlinable public
    var editionDependencies:EditionDependencies { .init(database: self.id) }
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
        try await self.packageBuilds.setup(with: session)
        try await self.packages.setup(with: session)
        try await self.editions.setup(with: session)
        try await self.snapshots.setup(with: session)
        try await self.sitemaps.setup(with: session)
        try await self.metadata.setup(with: session)

        try await self.packageDependencies.setup(with: session)
        try await self.editionDependencies.setup(with: session)
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
        version:SemanticVersion?,
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
                release: version?.release ?? false,
                semver: version?.number,
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
    func store(linking documentation:SymbolGraphObject<Void>,
        with session:Mongo.Session) async throws -> (Unidoc.UploadStatus, Unidoc.UplinkStatus)
    {
        var snapshot:Unidoc.Snapshot
        let realm:Unidoc.Realm?

        //  Don’t queue for uplink, since we’re going to do that synchronously.
        (snapshot, realm) = try await self.label(documentation: documentation,
            action: nil,
            with: session)

        enum NoLoader:Unidoc.GraphLoader
        {
            func load(graph:Unidoc.GraphPath) async throws -> ArraySlice<UInt8>
            {
                fatalError("unreachable")
            }
        }

        let volume:Unidoc.Volume = try await self.link(&snapshot,
            symbol: documentation.metadata.package.id,
            loader: nil as NoLoader?,
            realm: realm,
            with: session)
        let symbol:Symbol.Volume = volume.metadata.symbol

        let uploaded:Unidoc.UploadStatus = try await self.snapshots.upsert(
            snapshot: /* consume */ snapshot, // https://github.com/apple/swift/issues/71605
            with: session)

        let uplinked:Unidoc.UplinkStatus = .init(
            edition: uploaded.edition,
            volume: symbol,
            hiddenByPackage: true,
            delta: try await self.fill(volume: consume volume,
                hidden: false,
                with: session))

        return (uploaded, uplinked)
    }

    /// Indexes and stores a symbol graph in the database, queueing it for an **asynchronous**
    /// uplink.
    @_spi(testable)
    public
    func store(docs documentation:consuming SymbolGraphObject<Void>,
        with session:Mongo.Session) async throws -> Unidoc.UploadStatus
    {
        let (snapshot, _):(Unidoc.Snapshot, Unidoc.Realm?) = try await self.label(
            documentation: documentation,
            action: .uplinkInitial,
            with: session)

        return try await self.snapshots.upsert(snapshot: snapshot, with: session)
    }

    public
    func label(
        documentation:consuming SymbolGraphObject<Void>,
        action:Unidoc.LinkerAction?,
        with session:Mongo.Session) async throws ->
        (
            snapshot:Unidoc.Snapshot,
            realm:Unidoc.Realm?
        )
    {
        let (package, _):(Unidoc.PackageMetadata, Bool) = try await self.index(
            package: documentation.metadata.package.id,
            repo: nil,
            with: session)

        let edition:Unidoc.EditionMetadata
        if  let commit:SymbolGraphMetadata.Commit = documentation.metadata.commit
        {
            (edition, _) = try await self.index(
                package: package.id,
                version: documentation.metadata.package.name.version(tag: commit.name),
                name: commit.name,
                sha1: commit.sha1,
                with: session)
        }
        else
        {
            //  Local documentation bypasses edition placement!
            //
            //  Local documentation is always considered release documentation, because usually
            //  one’s intent is to preview how the documentation will look when it is released.
            edition = .init(id: .init(package: package.id, version: -1),
                release: true,
                semver: .max,
                name: "__local",
                sha1: nil)

            try await self.editions.upsert(some: edition, with: session)
        }

        let snapshot:Unidoc.Snapshot = .init(id: edition.id,
            metadata: documentation.metadata,
            inline: documentation.graph,
            action: action)

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

        let volume:Unidoc.Volume = try await self.link(&snapshot,
            symbol: package.symbol,
            loader: loader,
            realm: package.realm,
            with: session)
        let symbol:Symbol.Volume = volume.metadata.symbol

        if  stored != snapshot
        {
            try await self.snapshots.update(some: snapshot, with: session)
        }

        return .init(
            edition: id,
            volume: symbol,
            hiddenByPackage: package.hidden,
            delta: try await self.fill(volume: consume volume,
                hidden: package.hidden,
                with: session))
    }

    public
    func unlink(_ id:Unidoc.Edition,
        with session:Mongo.Session) async throws -> Unidoc.UnlinkStatus?
    {
        guard
        let volume:Unidoc.VolumeMetadata = try await self.volumes.find(id: id,
            with: session)
        else
        {
            return nil
        }

        try await self.unlink(volume: volume, with: session)
        return .unlinked(volume.id)
    }

    private
    func unlink(volume:Symbol.Volume,
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
            try await self.unlink(volume: volume, with: session)
            return .unlinked(volume.id)
        }
        else
        {
            return .declined(volume.id)
        }
    }

    @discardableResult
    private
    func unlink(volume:Unidoc.VolumeMetadata,
        with session:Mongo.Session) async throws -> Bool
    {
        try await self.editionDependencies.clear(dependent: volume.id, with: session)
        try await self.packageDependencies.clear(dependent: volume.id, with: session)

        try await self.vertices.clear(range: volume.id, with: session)
        try await self.groups.clear(range: volume.id, with: session)
        try await self.trees.clear(range: volume.id, with: session)

        try await self.search.delete(id: volume.symbol, with: session)
        //  Delete this last, otherwise if one of the other steps fails, we won’t
        //  have an easy way to clean up the remaining documents.
        return try await self.volumes.delete(id: volume.id, with: session)
    }
}
extension Unidoc.DB
{
    private
    func fillEdges(from metadata:Unidoc.VolumeMetadata,
        hidden:Bool,
        with session:Mongo.Session) async throws
    {
        try await self.editionDependencies.insert(dependencies: metadata.dependencies,
            dependent: metadata.id,
            with: session)

        guard metadata.latest
        else
        {
            return
        }

        if  hidden
        {
            try await self.packageDependencies.clear(dependent: metadata.id, with: session)
        }
        else
        {
            try await self.packageDependencies.update(dependencies: metadata.dependencies,
                dependent: metadata.id,
                with: session)
        }
    }

    private
    func fill(volume:consuming Unidoc.Volume,
        hidden:Bool,
        with session:Mongo.Session) async throws -> Unidoc.SurfaceDelta?
    {
        //  We assume compressing the search JSON will take a (relatively) long time, so we do
        //  it before performing any database operations.
        //
        //  Our gzip compression is about 1.5 percent worse than Amazon CloudFront’s
        //  compression, which uses the Brotli algorithm. But it saves us local disk space,
        //  because we always store a copy of the search index in the database.
        //
        //  Amazon CloudFront will not re-compress files we have already compressed, so this
        //  means users will need to download 1.5 percent more data to use the search index.
        //  We think this is an acceptable trade-off, because compressing the search index
        //  locally means we can add more symbols to each search index.
        //
        //  We could get the best of both worlds by decompressing the search index before
        //  transferring it out to Amazon CloudFront. But that just doesn’t seem worth the CPU
        //  cycles, either for us or for Amazon.
        let search:Unidoc.TextResource<Symbol.Volume> = .init(id: volume.id,
            text: .init(compressing: volume.index.utf8))

        let volumeReplaced:Bool = try await self.unlink(volume: volume.metadata,
            with: session)

        //  If there is a volume generated from a prerelease with the same patch number,
        //  we need to delete that too.
        if  let occupant:Unidoc.VolumeMetadata = try await self.volumes.find(named: volume.id,
                with: session)
        {
            //  We should not clear release versions by name, only by coordinate.
            guard case nil = occupant.patch
            else
            {
                return nil
            }

            try await self.unlink(volume: occupant, with: session)
        }

        try await self.volumes.insert(some: volume.metadata, with: session)
        try await self.search.insert(some: search, with: session)
        try await self.trees.insert(some: volume.trees, with: session)

        try await self.vertices.insert(volume.vertices, with: session)
        try await self.groups.insert(volume.groups,
            realm: volume.metadata.latest ? volume.metadata.realm : nil,
            with: session)

        try await self.fillEdges(from: volume.metadata, hidden: hidden, with: session)

        let surfaceDelta:Unidoc.SurfaceDelta?
        if  volume.metadata.latest
        {
            var new:Unidoc.Sitemap = volume.sitemap()

            if  let sitemapDelta:Unidoc.SitemapDelta = try await self.sitemaps.diff(new: new,
                    with: session)
            {
                if  hidden
                {
                    surfaceDelta = .ignoredPrivate
                    try await self.sitemaps.delete(id: new.id, with: session)
                }
                else if case .zero = sitemapDelta
                {
                    surfaceDelta = volumeReplaced ? .ignoredRepeated(nil) : .replaced(nil)
                }
                else
                {
                    surfaceDelta = volumeReplaced
                        ? .ignoredRepeated(sitemapDelta)
                        : .replaced(sitemapDelta)

                    new.modified = .now()
                    try await self.sitemaps.upsert(some: new, with: session)
                }
            }
            else if hidden
            {
                surfaceDelta = .ignoredPrivate
            }
            else
            {
                //  No pre-existing sitemap.
                surfaceDelta = .initial
                try await self.sitemaps.upsert(some: new, with: session)
            }
        }
        else
        {
            surfaceDelta = .ignoredHistorical
        }

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

        return surfaceDelta
    }

    /// Pins as many of the snapshot’s dependencies as possible. After this function returns,
    /// the `snapshot` will contain a list of ``Snapshot/pins`` matching the length of the
    /// ``SymbolGraphMetadata/dependencies`` list. The two arrays will share indices.
    private
    func pin(_ snapshot:inout Unidoc.Snapshot, with session:Mongo.Session) async throws
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
            return
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
    }

    private
    func link(_ snapshot:inout Unidoc.Snapshot,
        symbol package:Symbol.Package,
        loader:(some Unidoc.GraphLoader)?,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws -> Unidoc.Volume
    {
        try await self.pin(&snapshot, with: session)
        var linker:Unidoc.Linker = try await self.snapshots.load(for: snapshot,
            from: loader,
            with: session)

        let dependencies:[Unidoc.VolumeMetadata.Dependency] = linker.dependencies(
            pinned: snapshot.pins)

        let mesh:Unidoc.Linker.Mesh = linker.link(around: .init(id: snapshot.id.global,
            snapshot: .init(abi: snapshot.metadata.abi,
                latestManifest: snapshot.metadata.tools,
                extraManifests: snapshot.metadata.manifests,
                requirements: snapshot.metadata.requirements,
                commit: snapshot.metadata.commit?.sha1),
            packages: snapshot.pins.compactMap(\.?.package)))

        linker.status().emit(colors: .enabled)

        let latestRelease:Unidoc.Edition?
        let thisRelease:PatchVersion?
        let version:String

        //  Yes, the standard library always has a commit, although we don’t always have a
        //  commit hash.
        versioning:
        if  let commit:SymbolGraphMetadata.Commit = snapshot.metadata.commit
        {
            let formerRelease:Volumes.PatchView? = try await self.volumes.latestRelease(
                of: snapshot.id.package,
                with: session)

            guard
            let semver:SemanticVersion = snapshot.metadata.package.name.version(
                tag: commit.name)
            else
            {
                latestRelease = formerRelease?.id
                thisRelease = nil
                version = commit.name

                break versioning
            }

            switch semver.suffix
            {
            case .prerelease(_, build: _):
                latestRelease = formerRelease?.id
                thisRelease = nil

            case .release(build: _):
                if  let formerRelease:Volumes.PatchView,
                        formerRelease.patch > semver.number
                {
                    latestRelease = formerRelease.id
                }
                else
                {
                    latestRelease = snapshot.id
                }

                thisRelease = semver.number
            }

            version = "\(semver.number)"
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
