import HTTP
import MongoDB
import UnidocDB

extension Server.Endpoint
{
    struct _RecentActivity:Sendable
    {
        init()
        {
        }
    }
}
extension Server.Endpoint._RecentActivity:RestrictedEndpoint
{
    func load(from server:Server.InteractiveState) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let feed:[UnidocDatabase.RepoActivity] = try await server.db.unidoc.repoFeed.last(16,
            with: session)

        var text:String = ""

        for item:UnidocDatabase.RepoActivity in feed
        {
            text += "\(item.package) @ \(item.refname)\n"
        }

        return .ok(.init(
            content: .string(text),
            type: .text(.plain, charset: .utf8)))
    }
}
