import GitHubClient
import GitHubAPI
import HTTP
import ModuleGraphs
import MongoDB
import SymbolGraphs
import UnidocDB

extension Server.Endpoint
{
    struct _SyncRepository:Sendable
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
extension Server.Endpoint._SyncRepository:RestrictedEndpoint
{
    func load(from server:Server.InteractiveState) async throws -> ServerResponse?
    {
        guard
        let github:GitHubClient<GitHub.API> = server.github?.api
        else
        {
            return nil
        }

        let repo:GitHub.Repo = try await github.get(
            from: "/repos/\(self.owner)/\(self.repo)")

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let package:Int32 = try await server.db.unidoc.track(repo: repo,
            with: session)


        return .ok(.init(
            content: .string("""
                Cell: \(package)

                \(repo)
                """),
            type: .text(.plain, charset: .utf8)))
    }
}
