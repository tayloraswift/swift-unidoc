import HTTP
import MongoDB
import UnidocUI

extension Unidoc
{
    enum LoadDashboardOperation
    {
        case logger
        case plugin(String)
        case replicaSet
    }
}
extension Unidoc.LoadDashboardOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        switch self
        {
        case .logger:
            guard
            let logger:any Unidoc.ServerLogger = server.logger
            else
            {
                return .notFound("No logging enabled\n")
            }

            return .ok(await logger.dashboard(from: server, as: format))

        case .plugin(let id):
            guard
            let plugin:any Unidoc.ServerPlugin = server.plugins[id]
            else
            {
                return .notFound("No such plugin")
            }
            guard
            let page:any Unidoc.RenderablePage = plugin.page
            else
            {
                return .notFound("This plugin has not been initialized yet")
            }

            return .ok(page.resource(format: format))

        case .replicaSet:
            let configuration:Mongo.ReplicaSetConfiguration = try await session.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin)

            let page:Unidoc.ReplicaSetPage = .init(configuration: configuration)
            return .ok(page.resource(format: format))
        }
    }
}
