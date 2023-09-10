import GitHubClient
import GitHubIntegration
import HTTP
import ModuleGraphs
import MongoDB
import SymbolGraphs
import UnidocDatabase

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
extension Server.Endpoint._SyncRepository:RestrictedOperation
{
    func load(from services:Services) async throws -> ServerResponse?
    {
        guard let github:GitHubClient<GitHubAPI> = services.github?.api
        else
        {
            return nil
        }

        let repo:GitHubAPI.Repo = try await github.get(
            from: "/repos/\(self.owner)/\(self.repo)")

        let session:Mongo.Session = try await .init(from: services.database.sessions)
        let package:Int32 = try await services.database.package.track(repo: repo,
            with: session)

        let tags:[GitHubAPI.Tag] = try await github.get(
            from: "/repos/\(self.owner)/\(self.repo)/tags")

        var old:[GitHubAPI.Tag] = []
        var new:[GitHubAPI.Tag] = []

        for tag:GitHubAPI.Tag in tags
        {
            switch try await services.database.package.editions.register(tag,
                package: package,
                with: session)
            {
            case nil:   old.append(tag)
            case _?:    new.append(tag)
            }
        }

        return .resource(.init(.one(canonical: nil),
            content: .string("""
                \(repo)

                Known Tags: \(old)
                New Tags: \(new)
                """),
            type: .text(.plain, charset: .utf8)))
    }
}
