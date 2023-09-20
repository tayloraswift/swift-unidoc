import GitHubClient
import GitHubAPI
import HTTP
import ModuleGraphs
import MongoDB
import SymbolGraphs
import UnidocDB

extension Server.Operation
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
extension Server.Operation._SyncRepository:RestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        guard
        let github:GitHubClient<GitHubOAuth.API> = server.github?.api
        else
        {
            return nil
        }

        let repo:GitHub.Repo = try await github.get(
            from: "/repos/\(self.owner)/\(self.repo)")

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let package:Int32 = try await server.db.package.track(repo: repo,
            with: session)

        let tags:[GitHub.Tag] = try await github.get(
            from: "/repos/\(self.owner)/\(self.repo)/tags")

        var old:[GitHub.Tag] = []
        var new:[GitHub.Tag] = []

        //  Import tags in chronological order.
        for tag:GitHub.Tag in tags.reversed()
        {
            switch try await server.db.package.editions.register(tag,
                package: package,
                with: session)
            {
            case nil:   old.append(tag)
            case _?:    new.append(tag)
            }
        }

        return .resource(.init(.one(canonical: nil),
            content: .string("""
                Cell: \(package)

                \(repo)

                Known Tags: \(old)
                New Tags: \(new)
                """),
            type: .text(.plain, charset: .utf8)))
    }
}
