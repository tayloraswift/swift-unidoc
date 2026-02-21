import HTTP
import MongoDB
import UnidocUI

extension Unidoc {
    enum LoadDashboardOperation {
        case logger
        case replicaSet
    }
}
extension Unidoc.LoadDashboardOperation: Unidoc.AdministrativeOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as format: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        switch self {
        case .logger:
            return .ok(await server.logger.dashboard(from: server, as: format))

        case .replicaSet:
            let configuration: Mongo.ReplicaSetConfiguration = try await db.session.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin
            )

            let page: Unidoc.ReplicaSetPage = .init(configuration: configuration)
            return .ok(page.resource(format: format))
        }
    }
}
