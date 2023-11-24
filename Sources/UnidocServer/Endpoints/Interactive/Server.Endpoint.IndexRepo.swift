import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import SymbolGraphs
import UnidocDB

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

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let package:Int32 = try await server.db.unidoc.track(repo: response.repo,
            with: session)

        //  Discard the tags for now, we want them to get indexed by the crawler.

        return .ok(.init(
            content: .string("""
                Cell: \(package)
                """),
            type: .text(.plain, charset: .utf8)))
    }
}
