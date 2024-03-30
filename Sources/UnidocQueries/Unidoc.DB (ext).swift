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
    //  TODO: we want this to return ``Unidoc.BuildLabels``, but the `_allSymbolGraphs` case
    //  is preventing us from doing so. This means we can’t guarantee on the server side yet
    //  that the labels contain a buildable tag.
    public
    func answer(prompt:Unidoc.BuildLabelsPrompt,
        with session:Mongo.Session) async throws -> JSON?
    {
        switch prompt
        {
        case ._allSymbolGraphs(upTo: let version, limit: let limit):
            let editions:[Unidoc.Edition] = try await self.snapshots.oldest(limit ?? 16,
                until: version,
                with: session)

            return .array
            {
                for id:Unidoc.Edition in editions
                {
                    $0[+] = id
                }
            }

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

            let build:Unidoc.BuildLabels = .init(coordinate: id,
                package: output.package.symbol,
                repo: repo.origin.https,
                tag: output.edition.name)

            return .object(with: build.encode(to:))

        case .package(let package, series: let series):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.BuildTagQuery> = .init(
                query: .init(package: package, version: series ?? .release))

            try await pipeline.pull(from: self.id, with: session)

            guard
            let output:Unidoc.BuildTagQuery.Output = pipeline.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            let build:Unidoc.BuildLabels

            if  case _? = series
            {
                build = .init(coordinate: output.version.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: output.version.edition.name)
            }
            else
            {
                build = .init(coordinate: output.version.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: output.version.graph == nil ? output.version.edition.name : nil)
            }

            return .object(with: build.encode(to:))

        case .packageNamed(let package, series: let series):
            let filter:Unidoc.VersionsQuery.Predicate

            switch series
            {
            case .none:         filter = .tags(limit: 1, series: .release)
            case .release?:     filter = .tags(limit: 1, series: .release)
            case .prerelease?:  filter = .tags(limit: 1, series: .prerelease)
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

            let build:Unidoc.BuildLabels

            if  let series:Unidoc.VersionSeries
            {
                let tag:Unidoc.Versions.Tag?

                switch series
                {
                case .release:      tag = output.versions.releases.first
                case .prerelease:   tag = output.versions.prereleases.first
                }

                guard
                let tag:Unidoc.Versions.Tag
                else
                {
                    return nil
                }

                build = .init(coordinate: tag.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: tag.edition.name)
            }
            else
            {
                guard
                let tag:Unidoc.Versions.Tag = output.versions.releases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: tag.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: tag.graph == nil ? tag.edition.name : nil)
            }

            return .object(with: build.encode(to:))
        }
    }
}
