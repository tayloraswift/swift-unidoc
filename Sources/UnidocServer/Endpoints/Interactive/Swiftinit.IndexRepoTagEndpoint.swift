import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import SemanticVersions
import Symbols
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct IndexRepoTagEndpoint:Sendable
    {
        let package:Symbol.Package
        let tag:String

        init(package:Symbol.Package, tag:String)
        {
            self.package = package
            self.tag = tag
        }
    }
}
extension Swiftinit.IndexRepoTagEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:Swiftinit.PluginIntegration<GitHubPlugin> = server.plugins.github
        else
        {
            return nil
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let package:Unidex.Package = try await server.db.unidoc.execute(
            query: Unidex.PackageQuery.init(symbol: self.package),
            with: session)
        else
        {
            return .notFound("No such package")
        }

        guard
        case .github(let repo) = package.repo
        else
        {
            return .notFound("Not a GitHub repository")
        }

        let response:GitHubPlugin.TagResponse = try await github.api.connect
        {
            try await $0.inspect(tag: self.tag,
                owner: repo.owner.login,
                repo: repo.name,
                pat: github.plugin.pat)
        }

        guard
        let tag:GitHub.Tag = response.tag
        else
        {
            return .notFound("No such tag")
        }

        guard
        let version:SemanticVersion = package.symbol.version(tag: tag.name)
        else
        {
            return .ok("Ignored tag '\(tag.name)': not a semantic or swift version")
        }

        let (edition, new):(Unidex.Edition, Bool) = try await server.db.unidoc.register(
            package: package.id,
            version: version,
            refname: tag.name,
            sha1: tag.hash,
            with: session)

        return .ok("""
            \(new ? "Created" : "Updated") tag '\(edition.name)' as '\(version)' \
            (version = \(edition.id))
            """)
    }
}
