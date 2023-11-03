import HTTP
import MongoDB
import UnidocPages

extension Server.Endpoint
{
    enum AdminDashboard
    {
        case status
    }
}
extension Server.Endpoint.AdminDashboard:RestrictedEndpoint
{
    func load(from server:isolated Server) async throws -> HTTP.ServerResponse?
    {
        let page:Site.Admin = .init(configuration: try await server.db.sessions.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin),
            requestsDropped: server.count.requestsDropped.load(ordering: .relaxed),
            errorsCrawling: server.count.errorsCrawling.load(ordering: .relaxed),
            reposCrawled: server.count.reposCrawled.load(ordering: .relaxed),
            reposUpdated: server.count.reposUpdated.load(ordering: .relaxed),
            tagsCrawled: server.count.tagsCrawled.load(ordering: .relaxed),
            tagsUpdated: server.count.tagsUpdated.load(ordering: .relaxed),
            tour: server.tour,
            real: server.secured)

        return .ok(page.resource(assets: server.assets))
    }
}
