import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct PackageIndexEndpoint:Sendable
    {
        let owner:String
        let repo:String

        init(owner:String, repo:String)
        {
            self.owner = owner
            self.repo = repo
        }
    }
}
extension Swiftinit.PackageIndexEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:Swiftinit.PluginIntegration<GitHubPlugin> = server.plugins.github
        else
        {
            return nil
        }

        let response:GitHubPlugin.RepoMonitorResponse = try await github.api.connect
        {
            try await $0.crawl(owner: self.owner,
                repo: self.repo,
                pat: github.plugin.pat)
        }

        //  Discard the tags for now, we want them to get indexed by the crawler.
        guard
        let repo:GitHub.Repo = response.repo
        else
        {
            return .notFound("No such repo.")
        }

        guard repo.owner.login.allSatisfy({ $0 != "." })
        else
        {
            return .ok("Cannot index a repo with a dot in the owner’s name.")
        }

        // let symbol:Symbol.Package = .init("\(repo.owner.login).\(repo.name)")
        let symbol:Symbol.Package = .init(repo.name)
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        let (package, new):(Unidoc.PackageMetadata, Bool) = try await server.db.unidoc.index(
            package: symbol,
            repo: .github(repo),
            with: session)

        return .ok("""
            Cell: \(package.id)
            New: \(new)
            """)
    }
}
