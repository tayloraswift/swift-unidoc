import HTTP
import MongoDB
import UnidocPages

extension Swiftinit
{
    enum AdminDashboardEndpoint
    {
        case status
    }
}
extension Swiftinit.AdminDashboardEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let configuration:Mongo.ReplicaSetConfiguration = try await server.db.sessions.run(
            command: Mongo.ReplicaSetGetConfiguration.init(),
            against: .admin)

        let page:Site.Admin =
        {
            (counters:borrowing Swiftinit.Counters) in

            .init(configuration: configuration,
                requestsDropped: counters.requestsDropped.load(ordering: .relaxed),
                errorsCrawling: counters.errorsCrawling.load(ordering: .relaxed),
                reposCrawled: counters.reposCrawled.load(ordering: .relaxed),
                reposUpdated: counters.reposUpdated.load(ordering: .relaxed),
                tagsCrawled: counters.tagsCrawled.load(ordering: .relaxed),
                tagsUpdated: counters.tagsUpdated.load(ordering: .relaxed),
                tour: server.tour,
                real: server.secured)
        } (server.atomics)

        return .ok(page.resource(format: .init(assets: server.assets)))
    }
}
