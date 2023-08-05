import HTML
import HTTPServer
import MongoDB

extension Delegate.Get
{
    struct Admin:Sendable
    {
        let tool:Tool?

        init(tool:Tool?)
        {
            self.tool = tool
        }
    }
}
extension Delegate.Get.Admin
{
    func load(pool:Mongo.SessionPool) async throws -> ServerResponse
    {
        let resource:ServerResource
        switch self.tool
        {
        case nil:
            let page:Site.Admin = .init(configuration: try await pool.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            resource = page.rendered()

        case .dropDatabase:
            let page:Site.Admin.DropDatabase = .init()

            resource = page.rendered()
        }
        return .resource(resource)
    }
}
