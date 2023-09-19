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
    func load(from server:ServerState) async throws -> ServerResponse?
    {
        let page:Site.Admin = .init(configuration: try await server.db.sessions.run(
                    command: Mongo.ReplicaSetGetConfiguration.init(),
                    against: .admin),
                tour: server.tour,
                real: server.mode == .secured)

        return .resource(page.rendered())
    }
}
