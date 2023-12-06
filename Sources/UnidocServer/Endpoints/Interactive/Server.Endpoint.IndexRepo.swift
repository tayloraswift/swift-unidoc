import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    struct IndexRepo:Sendable
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
extension Server.Endpoint.IndexRepo:RestrictedEndpoint
{
    func load(from server:Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:Server.PluginIntegration<GitHubPlugin> = server.github
        else
        {
            return nil
        }

        let response:GitHubPlugin.CrawlerResponse = try await github.api.connect
        {
            try await $0.crawl(owner: self.owner,
                repo: self.repo,
                pat: github.plugin.pat)
        }

        //  Discard the tags for now, we want them to get indexed by the crawler.
        let repo:GitHub.Repo = (consume response).repo

        guard repo.owner.login.allSatisfy({ $0 != "." })
        else
        {
            return .ok("Cannot index a repo with a dot in the owner’s name.")
        }

        // let symbol:Symbol.Package = .init("\(repo.owner.login).\(repo.name)")
        let symbol:Symbol.Package = .init(repo.name)
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        let (package, new):(Unidex.Package, Bool) = try await server.db.unidoc.register(symbol,
            tracking: .github(repo),
            with: session)

        return .ok("""
            Cell: \(package.id)
            New: \(new)
            """)
    }
}
