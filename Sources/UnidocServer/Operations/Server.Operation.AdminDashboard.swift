import HTTP
import MongoDB
import UnidocPages

extension Server.Operation
{
    enum AdminDashboard
    {
        case status
    }
}
extension Server.Operation.AdminDashboard:RestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        let page:Site.Admin = .init(configuration: try await server.db.sessions.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin),
            errorsCrawling: server.github?.errors ?? 0,
            reposCrawled: server.github?.reposCrawled ?? 0,
            reposUpdated: server.github?.reposUpdated ?? 0,
            tagsCrawled: server.github?.tagsCrawled ?? 0,
            tagsUpdated: server.github?.tagsUpdated ?? 0,
            tour: server.tour,
            real: server.mode == .secured)

        return .ok(page.resource())
    }
}
