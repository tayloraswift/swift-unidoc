import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import SemanticVersions
import Symbols
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    struct IndexRepoTag:Sendable
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
extension Server.Endpoint.IndexRepoTag:RestrictedEndpoint
{
    func load(from server:Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:Server.PluginIntegration<GitHubPlugin> = server.github
        else
        {
            return nil
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let output:Unidex.EditionsQuery.Output = try await server.db.unidoc.execute(
            query: Unidex.EditionsQuery.init(package: self.package, limit: 0),
            with: session)
        else
        {
            return .notFound("No such package")
        }

        let package:Unidex.Package = (consume output).package

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
