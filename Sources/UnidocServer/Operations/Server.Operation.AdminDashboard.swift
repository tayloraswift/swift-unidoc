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
                crawlingErrors: server._crawlingErrors.load(ordering: .relaxed),
                packagesCrawled: server._packagesCrawled.load(ordering: .relaxed),
                packagesUpdated: server._packagesUpdated.load(ordering: .relaxed),
                tagsCrawled: server._tagsCrawled.load(ordering: .relaxed),
                tagsUpdated: server._tagsUpdated.load(ordering: .relaxed),
                tour: server.tour,
                real: server.mode == .secured)

        return .resource(page.rendered())
    }
}
