import BSON
import FNV1
import MD5
import MongoDB
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI
import UnidocLinking
import UnidocRecords_LZ77
@_spi(testable)
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct DB:Identifiable
    {
        public
        let session:Mongo.Session
        public
        let id:Mongo.Database

        public
        let policy:SecurityPolicy

        @inlinable public
        init(session:Mongo.Session,
            in id:Mongo.Database,
            policy:SecurityPolicy = .init(security: .enforced))
        {
            self.session = session
            self.id = id
            self.policy = policy
        }
    }
}
extension Unidoc.DB
{
    @inlinable public
    var searchbotCoverage:SearchbotCoverage
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var searchbotGrid:SearchbotGrid
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var crawlingTickets:CrawlingTickets
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var crawlingWindows:CrawlingWindows
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var pendingBuilds:PendingBuilds
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var completeBuilds:CompleteBuilds
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var repoFeed:RepoFeed
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var docsFeed:DocsFeed
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var realmAliases:RealmAliases
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var realms:Realms
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var packageAliases:PackageAliases
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var packages:Packages
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var editions:Editions
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var snapshots:Snapshots
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var sitemaps:Sitemaps
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var metadata:Metadata
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var packageDependencies:PackageDependencies
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var editionDependencies:EditionDependencies
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var volumes:Volumes
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var redirects:Redirects
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var vertices:Vertices
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var groups:Groups
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var search:Search
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var trees:Trees
    {
        .init(database: self.id, session: self.session)
    }

    @inlinable public
    var users:Users
    {
        .init(database: self.id, session: self.session)
    }
}
extension Unidoc.DB:Mongo.DatabaseModel
{
    public
    func setup() async throws
    {
        try await self.searchbotGrid.setup()
        try await self.crawlingTickets.setup()
        try await self.crawlingWindows.setup()
        try await self.repoFeed.setup()
        try await self.docsFeed.setup()
        try await self.pendingBuilds.setup()
        try await self.completeBuilds.setup()

        try await self.realmAliases.setup()
        try await self.realms.setup()
        try await self.packageAliases.setup()
        try await self.packages.setup()
        try await self.editions.setup()
        try await self.snapshots.setup()
        try await self.sitemaps.setup()
        try await self.metadata.setup()

        try await self.packageDependencies.setup()
        try await self.editionDependencies.setup()
        try await self.volumes.setup()
        try await self.redirects.setup()
        try await self.vertices.setup()
        try await self.groups.setup()
        try await self.search.setup()
        try await self.trees.setup()

        try await self.users.setup()
    }
}

extension Unidoc.DB
{
    /// Registers an **alias** of a package realm.
    public
    func index(realm:String) async throws -> (realm:Unidoc.RealmMetadata, new:Bool)
    {
        let autoincrement:Unidoc.Autoincrement<Unidoc.RealmMetadata> = try await self.query(
            with: Unidoc.AutoincrementQuery<RealmAliases, Realms>.init(symbol: realm))
            ?? .first

        switch consume autoincrement
        {
        case .new(let id):
            //  This can fail if we race with another process.
            try await self.realmAliases.insert(alias: realm, of: id)
            fallthrough

        case .old(let id, nil):
            //  Edge case: the most likely reason for this is that we successfully inserted
            //  the ``Unidoc.RealmAlias`` document, but failed to insert the
            //  ``Unidoc.RealmMetadata`` document.
            let realm:Unidoc.RealmMetadata = .init(id: id, symbol: realm)
            try await self.realms.insert(realm)
            return (realm, true)

        case .old(_, let realm?):
            return (realm, false)
        }
    }

    /// Registers an **alias** of a package.
    ///
    /// We currently only use this for testing purposes, as the web UI creates aliases directly
    /// using package coordinates.
    public
    func alias(
        existing package:Symbol.Package,
        package alias:Symbol.Package) async throws
    {
        guard
        let query:Unidoc.AliasQuery<PackageAliases> = .init(symbol: package, alias: alias)
        else
        {
            //  Symbols are the same.
            return
        }
        let _:Never? = try await self.query(with: query)
    }

    public
    func index(package:Symbol.Package,
        repo:Unidoc.PackageRepo? = nil,
        repoWebhook:String? = nil,
        mode:Unidoc.PackageIndexMode = .manual) async throws ->
    (
        package:Unidoc.PackageMetadata,
        new:Bool
    )
    {
        existingGitHub:
        if  let repo:Unidoc.PackageRepo,
            case .github(let origin) = repo.origin
        {
            let modified:Unidoc.PackageMetadata? = try await self.packages.modifyByRegistrar(
                github: origin.id)
            {
                $0[.set]
                {
                    $0[Unidoc.PackageMetadata[.repo]] = repo
                    $0[Unidoc.PackageMetadata[.repoWebhook]] = repoWebhook
                }
            }

            guard
            let modified:Unidoc.PackageMetadata
            else
            {
                break existingGitHub
            }

            if  modified.symbol != package
            {
                //  According to GitHub, this package is already known to us by another name.
                do
                {
                    try await self.packageAliases.insert(alias: package, of: modified.id)
                }
                catch is Mongo.WriteError
                {
                    //  Alias already exists.
                }
            }

            return (modified, false)
        }

        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Unidoc.Autoincrement<Unidoc.PackageMetadata> = try await self.query(
            with: Unidoc.AutoincrementQuery<PackageAliases, Packages>.init(symbol: package))
            ?? .first

        switch consume placement
        {
        case .new(let id):
            try await self.packageAliases.insert(alias: package, of: id)
            fallthrough

        case .old(let id, _):
            /// In very rare circumstances, the placement may be old but the package metadata
            /// may be new, if a previous indexing operation failed midway through.
            let (package, new):(Unidoc.PackageMetadata, Bool) = try await self.packages.upsert(
                id: id)
            {
                $0[.setOnInsert]
                {
                    $0[Unidoc.PackageMetadata[.hidden]] = mode == .automatic ? true : nil
                    $0[Unidoc.PackageMetadata[.symbol]] = package
                }
                $0[.set]
                {
                    $0[Unidoc.PackageMetadata[.repo]] = repo
                    $0[Unidoc.PackageMetadata[.repoWebhook]] = repoWebhook
                }
            }

            if !package.hidden, new
            {
                try await self.rebuildPackageList()
            }

            return (package, new)
        }
    }

    /// Registers an **edition** of a package.
    public
    func index(
        package:Unidoc.Package,
        version:SemanticVersion?,
        name:String,
        sha1:SHA1?) async throws -> (edition:Unidoc.EditionMetadata, new:Bool)
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Unidoc.EditionPlacement = try await self.query(
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
            try await self.editions.insert(edition)

            return (edition, true)

        case .old(var edition):
            if  let sha1:SHA1,
                    sha1 != edition.sha1
            {
                edition.sha1 = sha1
                try await self.editions.replace(edition)
            }

            return (edition, false)
        }
    }
}
extension Unidoc.DB
{
    public
    func label(docs:SymbolGraphMetadata) async throws ->
    (
        package:Unidoc.PackageMetadata,
        edition:Unidoc.EditionMetadata
    )
    {
        let (package, _):(Unidoc.PackageMetadata, Bool) = try await self.index(
            package: docs.package.id,
            repo: nil)

        let edition:Unidoc.EditionMetadata
        if  let commit:SymbolGraphMetadata.Commit = docs.commit
        {
            (edition, _) = try await self.index(
                package: package.id,
                version: docs.package.name.version(tag: commit.name),
                name: commit.name,
                sha1: commit.sha1)
        }
        else if
            case .swift = docs.package.name,
            case nil = docs.swift.nightly
        {
            (edition, _) = try await self.index(
                package: package.id,
                version: .release(docs.swift.version),
                name: "__Xcode",
                sha1: nil)
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

            try await self.editions.upsert(edition)
        }

        return (package, edition)
    }
}
extension Unidoc.DB
{
    public
    func uplink(snapshot:Unidoc.Snapshot,
        package:Unidoc.PackageMetadata,
        linker:some Unidoc.GraphLinker,
        loader:some Unidoc.GraphLoader) async throws -> Unidoc.UplinkStatus
    {
        let linked:Unidoc.Mesh = try await self.link(snapshot,
            symbol: package.symbol,
            linker: linker,
            loader: loader,
            realm: package.realm)

        return .init(edition: snapshot.id,
            volume: linked.volume,
            hiddenByPackage: package.hidden,
            delta: try await self.fillVolume(from: linked, hidden: package.hidden))
    }

    public
    func unlink(_ id:Unidoc.Edition) async throws -> Unidoc.UnlinkStatus?
    {
        guard
        let volume:Unidoc.VolumeMetadata = try await self.volumes.find(id: id)
        else
        {
            return nil
        }

        try await self.unlink(volume: volume)
        return .unlinked(volume.id)
    }

    private
    func unlink(volume:Symbol.Volume) async throws -> Unidoc.UnlinkStatus?
    {
        guard
        let volume:Unidoc.VolumeMetadata = try await self.volumes.find(named: volume)
        else
        {
            return nil
        }

        if  case nil = volume.patch
        {
            try await self.unlink(volume: volume)
            return .unlinked(volume.id)
        }
        else
        {
            return .declined(volume.id)
        }
    }

    @discardableResult
    private
    func unlink(volume:Unidoc.VolumeMetadata) async throws -> Bool
    {
        try await self.editionDependencies.clear(dependent: volume.id)
        try await self.packageDependencies.clear(dependent: volume.id)

        try await self.redirects.deleteAll(in: volume.id)
        try await self.vertices.deleteAll(in: volume.id)
        try await self.groups.deleteAll(in: volume.id)
        try await self.trees.deleteAll(in: volume.id)

        try await self.search.delete(id: volume.symbol)
        //  Delete this last, otherwise if one of the other steps fails, we won’t
        //  have an easy way to clean up the remaining documents.
        return try await self.volumes.delete(id: volume.id)
    }
}
extension Unidoc.DB
{
    private
    func fillEdges(from boundaries:[Unidoc.Mesh.Boundary],
        dependent:Unidoc.Edition,
        dependentABI:MD5,
        latest:Bool,
        hidden:Bool) async throws
    {
        //  Create edition dependencies. These dependencies are initially marked as clean,
        //  because we just linked the snapshot against them.
        try await self.editionDependencies.create(dependent: dependent, from: boundaries)

        //  Dirty any dependencies on this edition if the ABI has changed.
        try await self.editionDependencies.update(
            dependencyABI: dependentABI,
            dependency: dependent)

        guard latest
        else
        {
            return
        }

        if  hidden
        {
            try await self.packageDependencies.clear(dependent: dependent)
        }
        else
        {
            try await self.packageDependencies.update(dependent: dependent, from: boundaries)
        }
    }

    private
    func fillVolume(from mesh:consuming Unidoc.Mesh,
        hidden:Bool) async throws -> Unidoc.SurfaceDelta?
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
        let search:Unidoc.TextResource<Symbol.Volume> = .init(id: mesh.volume,
            text: .init(compressing: mesh.index.utf8))

        let volumeReplaced:Bool = try await self.unlink(volume: mesh.metadata)

        //  If there is a volume generated from a prerelease with the same patch number,
        //  we need to delete that too.
        if  let occupant:Unidoc.VolumeMetadata = try await self.volumes.find(named: mesh.volume)
        {
            //  We should not clear release versions by name, only by coordinate.
            guard case nil = occupant.patch
            else
            {
                return nil
            }

            try await self.unlink(volume: occupant)
        }

        try await self.volumes.insert(mesh.metadata)
        try await self.search.insert(search)
        try await self.trees.insert(mesh.trees)

        try await self.redirects.insert(mesh.redirects)
        try await self.vertices.insert(mesh.vertices)
        try await self.groups.insert(mesh.groups,
            realm: mesh.metadata.latest ? mesh.metadata.realm : nil)

        try await self.fillEdges(from: mesh.boundaries,
            dependent: mesh.id,
            dependentABI: mesh.packageABI,
            latest: mesh.metadata.latest,
            hidden: hidden)

        let surfaceDelta:Unidoc.SurfaceDelta?
        if  mesh.metadata.latest
        {
            var new:Unidoc.Sitemap = mesh.sitemap()

            if  let sitemapDelta:Unidoc.SitemapDelta = try await self.sitemaps.diff(new: new)
            {
                if  hidden
                {
                    surfaceDelta = .ignoredPrivate
                    try await self.sitemaps.delete(id: new.id)
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
                    try await self.sitemaps.upsert(new)
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
                try await self.sitemaps.upsert(new)
            }
        }
        else
        {
            surfaceDelta = .ignoredHistorical
        }

        alignment:
        if  let latest:Unidoc.Edition = mesh.latestRelease
        {
            try await self.update(with: Volumes.AlignLatest.init(to: latest))

            guard
            let realm:Unidoc.Realm = mesh.metadata.realm
            else
            {
                break alignment
            }

            try await self.update(with: Groups.AlignLatest.init(to: latest, in: realm))
        }

        return surfaceDelta
    }

    /// Pins as many of the snapshot’s dependencies as possible. The array returned matches the
    /// length of the ``SymbolGraphMetadata/dependencies`` list. The two will share indices.
    private
    func pin(_ snapshot:Unidoc.Snapshot) async throws -> [Unidoc.EditionMetadata?]
    {
        print("pinning dependencies for \(snapshot.metadata.package.name)...")

        let local:Bool = snapshot.metadata.commit == nil

        guard
        let query:Unidoc.PinDependenciesQuery = .init(for: snapshot, locally: local)
        else
        {
            return .init(repeating: nil, count: snapshot.metadata.dependencies.count)
        }

        var pins:[Symbol.Package: Unidoc.EditionMetadata] = [:]

        for dependency:Symbol.PackageDependency<Unidoc.EditionMetadata> in try await self.query(
            with: query)
        {
            pins[dependency.package] = dependency.version
        }

        return snapshot.metadata.dependencies.map
        {
            local ? pins[$0.package.name] : pins[$0.id]
        }
    }

    private
    func link(_ snapshot:Unidoc.Snapshot,
        symbol package:Symbol.Package,
        linker:some Unidoc.GraphLinker,
        loader:some Unidoc.GraphLoader,
        realm:Unidoc.Realm?) async throws -> Unidoc.Mesh
    {
        let latestRelease:Unidoc.Edition?
        let thisRelease:PatchVersion?
        let version:String

        //  On Linux, the standard library always has a commit, although we don’t always have a
        //  commit hash.
        versioning:
        if  let commit:SymbolGraphMetadata.Commit = snapshot.metadata.commit
        {
            let formerRelease:Volumes.PatchView? = try await self.volumes.latestRelease(
                of: snapshot.id.package)

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
        else if
            case .swift = snapshot.metadata.package.name,
            case nil = snapshot.metadata.swift.nightly
        {
            //  The default Xcode toolchain on macOS has a version, but no associated
            //  tags in the `swiftlang/swift` repo, so if we didn’t have this carve-out,
            //  we would always consider it local.
            if  let formerRelease:Volumes.PatchView = try await self.volumes.latestRelease(
                    of: snapshot.id.package),
                    formerRelease.patch > snapshot.metadata.swift.version
            {
                latestRelease = formerRelease.id
            }
            else
            {
                latestRelease = snapshot.id
            }

            thisRelease = snapshot.metadata.swift.version
            version = "\(snapshot.metadata.swift.version)"
        }
        else
        {
            //  Local packages are always considered release versions.
            latestRelease = snapshot.id
            thisRelease = .max
            version = "__max"
        }

        let dependencies:[Unidoc.EditionMetadata?] = try await self.pin(snapshot)
        let mesh:Unidoc.Mesh = linker.link(
            documentation: try await loader.load(snapshot),
            dependencies: try await loader.load(dependencies: dependencies,
                of: snapshot.metadata,
                in: self.snapshots),
            dependencyMetadata: dependencies,
            latestRelease: latestRelease,
            thisRelease: thisRelease,
            //  We want the version component of the volume symbol to be stable,
            //  so we only encode the patch version, even if the symbol graph is
            //  from a prerelease tag.
            as: .init(package: package, version: version),
            in: realm)

        return mesh
    }
}
extension Unidoc.DB
{
    //  Regenerates the JSON list of all packages.
    public
    func rebuildPackageList() async throws
    {
        let index:Unidoc.TextResource<Unidoc.DB.Metadata.Key> = try await self.packages.scan()
        try await self.metadata.upsert(index)
    }

    public
    func align(package:Unidoc.Package, realm:Unidoc.Realm?) async throws
    {
        try await self.update(with: Unidoc.DB.Packages.AlignRealm.aligning(package))

        groups:
        if  let realm:Unidoc.Realm
        {
            guard
            let latest:Volumes.PatchView = try await self.volumes.latestRelease(of: package)
            else
            {
                break groups
            }

            try await self.update(with: Groups.AlignLatest.init(to: latest.id, in: realm))
        }
        else
        {
            try await self.update(with: Groups.ClearLatest.init(from: package))
        }

        try await self.update(with: Volumes.AlignRealm.init(
            range: .package(package),
            to: realm))

        try await self.update(with: Packages.AlignRealm.aligned(package, to: realm))
    }
}
