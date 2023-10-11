import HTTP
import MongoDB
import UnidocDB
import UnidocPages

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

        let page:Site.RecentActivity = .init(repoActivity: consume feed)
        return .ok(page.resource())
    }
}
