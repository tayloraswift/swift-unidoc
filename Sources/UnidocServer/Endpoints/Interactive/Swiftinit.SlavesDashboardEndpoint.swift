import HTTP
import MongoDB
import UnidocDB
import UnidocPages
import UnidocRecords

extension Swiftinit
{
    enum SlavesDashboardEndpoint:Sendable
    {
        case status
        case scramble
    }
}
extension Swiftinit.SlavesDashboardEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let cookie:Unidoc.Cookie

        switch self
        {
        case .scramble:
            guard
            let changed:Unidoc.Cookie = try await server.db.users.scramble(
                user: .machine(0),
                with: session)
            else
            {
                //  If, for some reason, the account has disappeared, we'll just create
                //  a new one.
                fallthrough
            }

            cookie = changed

        case .status:
            cookie = try await server.db.users.update(
                user: .machine(0),
                with: session)
        }

        let page:Swiftinit.AdminPage.Slaves = .init(cookie: "\(cookie)")
        return .ok(page.resource(format: server.format))
    }
}
