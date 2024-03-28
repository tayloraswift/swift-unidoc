import HTTP
import JSON
import MongoQL
import SemanticVersions
import Symbols
import UnidocDB

extension Swiftinit
{
    enum BuilderEndpoint:Sendable
    {
        case oldest(until:PatchVersion)
        case edition(Unidoc.Edition)
        case request(Unidoc.BuildRequest, of:Symbol.Package)
    }
}

extension Swiftinit.BuilderEndpoint:Swiftinit.RestrictedEndpoint
{
    /// The builder endpoint is restricted to administratrices and machine users.
    func admit(level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        }
    }

    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let json:JSON

        switch self
        {
        case .oldest(until: let version):
            let editions:[Unidoc.Edition] = try await server.db.snapshots.oldest(16,
                until: version,
                with: session)

            json = .array
            {
                for id:Unidoc.Edition in editions
                {
                    $0[+] = id
                }
            }

        case .edition(let id):
            var endpoint:Mongo.SingleOutputFromPrimary<Unidoc.BuildEditionQuery> = .init(
                query: .init(edition: id))

            try await endpoint.pull(from: server.db.unidoc.id, with: session)

            guard
            let output:Unidoc.BuildEditionQuery.Output = endpoint.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            let build:Unidoc.BuildArguments = .init(coordinate: id,
                package: output.package.symbol,
                repo: repo.origin.https,
                tag: output.edition.name)

            json = .object(with: build.encode(to:))

        case .request(let subject, let package):
            let filter:Unidoc.VersionsQuery.Predicate

            switch subject
            {
            case .auto:         filter = .tags(limit: 1, series: .release)
            case .release:      filter = .tags(limit: 1, series: .release)
            case .prerelease:   filter = .tags(limit: 1, series: .prerelease)
            }

            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.VersionsQuery> = .init(
                query: .init(symbol: package, filter: filter))

            try await pipeline.pull(from: server.db.unidoc.id, with: session)

            guard
            let output:Unidoc.VersionsQuery.Output = pipeline.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            let build:Unidoc.BuildArguments

            switch subject
            {
            case .auto:
                guard
                let release:Unidoc.Versions.Tag = output.versions.releases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: release.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: release.graph == nil ? release.edition.name : nil)

            case .release:
                guard
                let release:Unidoc.Versions.Tag = output.versions.releases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: release.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: release.edition.name)

            case .prerelease:
                guard
                let prerelease:Unidoc.Versions.Tag = output.versions.prereleases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: prerelease.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: prerelease.edition.name)
            }

            json = .object(with: build.encode(to:))
        }

        return .ok(.init(content: .binary(json.utf8),
            type: .application(.json, charset: .utf8),
            gzip: false))
    }
}
