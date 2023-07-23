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
        switch self.tool
        {
        case nil:
            let page:Site.Admin.DashboardPage = .init(configuration: try await pool.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }

            return .resource(.init(.one(canonical: nil),
                content: .binary(html.utf8),
                type: .text(.html, charset: .utf8)))

        case .dropDatabase:
            let page:Site.Admin.DropDatabasePage = .init()
            let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }

            return .resource(.init(.one(canonical: nil),
                content: .binary(html.utf8),
                type: .text(.html, charset: .utf8)))
        }
    }
}
