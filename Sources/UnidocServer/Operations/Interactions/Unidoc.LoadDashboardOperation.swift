import HTTP
import MongoDB
import UnidocUI

extension Unidoc
{
    enum LoadDashboardOperation
    {
        case logger
        case cookie(scramble:Bool)
        case plugin(String)
        case replicaSet
    }
}
extension Unidoc.LoadDashboardOperation:Unidoc.AdministrativeOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
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

            return .ok(await logger.dashboard(from: server))

        case .cookie(scramble: let scramble):
            let secrets:Unidoc.UserSecrets

            switch scramble
            {
            case true:
                guard
                let changed:Unidoc.UserSecrets = try await server.db.users.scramble(
                    secret: .cookie,
                    user: .init(type: .unidoc, user: 0),
                    with: session)
                else
                {
                    //  If, for some reason, the account has disappeared, we'll just create
                    //  a new one.
                    fallthrough
                }

                secrets = changed

            case false:
                secrets = try await server.db.users.update(
                    user: .machine(0),
                    with: session)
            }

            let page:Unidoc.CookiePage = .init(secrets: secrets)
            return .ok(page.resource(format: server.format))

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

            return .ok(page.resource(format: server.format))

        case .replicaSet:
            let configuration:Mongo.ReplicaSetConfiguration = try await session.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin)

            let page:Unidoc.ReplicaSetPage = .init(configuration: configuration)
            return .ok(page.resource(format: server.format))
        }
    }
}
