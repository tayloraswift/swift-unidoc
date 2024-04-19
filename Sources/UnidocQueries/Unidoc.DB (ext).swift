import JSON
import MongoDB
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
}
extension Unidoc.DB
{
    public
    func answer(prompt:Unidoc.BuildLabelsPrompt,
        with session:Mongo.Session) async throws -> Unidoc.BuildLabels?
    {
        switch prompt
        {
        case .edition(let id):
            var endpoint:Mongo.SingleOutputFromPrimary<Unidoc.BuildEditionQuery> = .init(
                query: .init(edition: id))

            try await endpoint.pull(from: self.id, with: session)

            guard
            let output:Unidoc.BuildEditionQuery.Output = endpoint.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            return .init(coordinate: id,
                package: output.package.symbol,
                repo: repo.origin.https,
                tag: output.edition.name)

        case .package(let package, series: let series, force: let force):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.BuildTagQuery> = .init(
                query: .init(package: package, version: series))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.BuildTagQuery.Output = pipeline.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            if  force || output.version.graph == nil
            {
                return .init(coordinate: output.version.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: output.version.edition.name)
            }
            else
            {
                return nil
            }

        case .packageNamed(let package, series: let series, force: let force):
            let filter:Unidoc.VersionsQuery.Predicate

            switch series
            {
            case .release:      filter = .tags(limit: 1, series: .release)
            case .prerelease:   filter = .tags(limit: 1, series: .prerelease)
            }

            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.VersionsQuery> = .init(
                query: .init(symbol: package, filter: filter))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.VersionsQuery.Output = pipeline.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            let tag:Unidoc.Versions.Tag?

            switch series
            {
            case .release:      tag = output.versions.releases.first
            case .prerelease:   tag = output.versions.prereleases.first
            }

            if  let tag:Unidoc.Versions.Tag, force || tag.graph == nil
            {
                return .init(coordinate: tag.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: tag.edition.name)
            }
            else
            {
                return nil
            }
        }
    }
}
