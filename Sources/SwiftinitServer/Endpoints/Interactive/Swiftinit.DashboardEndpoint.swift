import HTTP
import MongoDB
import SwiftinitPages

extension Swiftinit
{
    enum DashboardEndpoint
    {
        case master
        case plugin(String)
    }
}
extension Swiftinit.DashboardEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        switch self
        {
        case .master:
            let configuration:Mongo.ReplicaSetConfiguration = try await server.db.sessions.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin)

            let page:Swiftinit.AdminPage =
            {
                (counters:borrowing Swiftinit.Counters) in

                .init(configuration: configuration,
                    requestsDropped: counters.requestsDropped.load(ordering: .relaxed),
                    plugins: server.plugins.values.sorted { $0.id < $1.id },
                    tour: server.tour,
                    real: server.secure)
            } (server.atomics)

            return .ok(page.resource(format: server.format))

        case .plugin(let id):
            guard
            let plugin:any Swiftinit.ServerPlugin = server.plugins[id]
            else
            {
                return .notFound("No such plugin")
            }
            guard
            let page:any Swiftinit.RenderablePage = plugin.page
            else
            {
                return .notFound("This plugin has not been initialized yet")
            }

            return .ok(page.resource(format: server.format))
        }
    }
}
