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
        case _latest(Unidoc.BuildLatest?, of:Symbol.Package)
    }
}

extension Swiftinit.BuilderEndpoint:RestrictedEndpoint
{
    static
    func admit(user:Unidoc.User.ID, level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        }
    }

    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
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
            var endpoint:Mongo.SingleOutputFromPrimary<Unidoc.BuilderQuery> = .init(
                query: .init(edition: id))

            try await endpoint.pull(from: server.db.unidoc.id, with: session)

            guard
            let output:Unidoc.BuilderQuery.Output = endpoint.value,
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

        case ._latest(let subject, let package):
            let filter:Unidoc.VersionsPredicate

            switch subject
            {
            case nil:           filter = .tags(limit: 1, beta: false)
            case .release?:     filter = .tags(limit: 1, beta: false)
            case .prerelease?:  filter = .tags(limit: 1, beta: true)
            }

            var endpoint:Mongo.SingleOutputFromPrimary<Unidoc.VersionsQuery> = .init(
                query: .init(symbol: package, filter: filter))

            try await endpoint.pull(from: server.db.unidoc.id, with: session)

            guard
            let output:Unidoc.VersionsQuery.Output = endpoint.value,
            let repo:Unidoc.PackageRepo = output.package.repo
            else
            {
                return nil
            }

            let build:Unidoc.BuildArguments

            switch subject
            {
            case nil:
                guard
                let release:Unidoc.VersionsQuery.Tag = output.releases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: release.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: release.graph == nil ? release.edition.name : nil)

            case .release?:
                guard
                let release:Unidoc.VersionsQuery.Tag = output.releases.first
                else
                {
                    return nil
                }

                build = .init(coordinate: release.edition.id,
                    package: output.package.symbol,
                    repo: repo.origin.https,
                    tag: release.edition.name)

            case .prerelease?:
                guard
                let prerelease:Unidoc.VersionsQuery.Tag = output.prereleases.first
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
