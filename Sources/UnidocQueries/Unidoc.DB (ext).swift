import MongoDB
import SHA1
import Symbols
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc.DB
{
    /// Load the metadata for a package by name. The returned package might have a different
    /// canonical name than the one provided.
    public
    func package(named symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await session.query(database: self.id,
            with: Unidoc.AliasResolutionQuery<PackageAliases, Packages>.init(symbol: symbol))
    }
    /// Load the metadata for a realm by name. The returned realm might have a different
    /// canonical name than the one provided.
    public
    func realm(named symbol:String,
        with session:Mongo.Session) async throws -> Unidoc.RealmMetadata?
    {
        try await session.query(database: self.id,
            with: Unidoc.AliasResolutionQuery<RealmAliases, Realms>.init(symbol: symbol))
    }

    public
    func edition(package:Symbol.Package,
        version:Unidoc.VersionPredicate,
        with session:Mongo.Session) async throws -> Unidoc.EditionOutput?
    {
        try await session.query(database: self.id,
            with: Unidoc.EditionMetadataSymbolicQuery.init(package: package, version: version))
    }

    public
    func editionState(package:Symbol.Package,
        version:Unidoc.VersionPredicate,
        with session:Mongo.Session) async throws -> Unidoc.EditionState?
    {
        try await session.query(database: self.id,
            with: Unidoc.EditionStateSymbolicQuery.init(package: package, version: version,
                includeBuild: true))
    }
}
extension Unidoc.DB
{
    public
    func answer(prompt:Unidoc.BuildLabelsPrompt,
        with session:Mongo.Session) async throws -> Unidoc.BuildLabels?
    {
        let package:Unidoc.PackageMetadata
        let version:Unidoc.VersionState
        let rebuild:Bool

        switch prompt
        {
        case .edition(let id, force: let force):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.EditionStateDirectQuery> = .init(
                query: .init(package: id.package, version: .exact(id.version)))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.EditionState = pipeline.value
            else
            {
                return nil
            }

            package = output.package
            version = output.version
            rebuild = force

        case .package(let id, series: let series, force: let force):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.EditionStateDirectQuery> = .init(
                query: .init(package: id, version: .match(.latest(series))))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.EditionState = pipeline.value
            else
            {
                return nil
            }

            package = output.package
            version = output.version
            rebuild = force

        case .packageNamed(let symbol, series: let series, force: let force):
            let filter:Unidoc.VersionsQuery.Predicate

            switch series
            {
            case .release:      filter = .tags(limit: 1, series: .release)
            case .prerelease:   filter = .tags(limit: 1, series: .prerelease)
            }

            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.VersionsQuery> = .init(
                query: .init(symbol: symbol, filter: filter))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.VersionsQuery.Output = pipeline.value,
            let tag:Unidoc.VersionState = output.versions.first
            else
            {
                return nil
            }

            package = output.package
            version = tag
            rebuild = force
        }

        guard
        let repo:Unidoc.PackageRepo = package.repo
        else
        {
            return nil
        }

        skipping:
        if  let graph:Unidoc.VersionState.Graph = version.graph
        {
            if  rebuild
            {
                break skipping
            }
            if  let built:SHA1 = graph.commit,
                let commit:SHA1 = version.edition.sha1,
                    commit != built
            {
                break skipping
            }
            else
            {
                return nil
            }
        }

        return .init(coordinate: version.edition.id,
            package: package.symbol,
            repo: repo.origin.https,
            ref: version.edition.name)
    }
}
