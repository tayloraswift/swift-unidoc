import HTTP
import MongoDB
import UnidocDB
import UnidocPages

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
        let cookie:Account.Cookie

        switch self
        {
        case .scramble:
            guard
            let changed:Account.Cookie = try await server.db.account.users.scramble(
                account: .machine(0),
                with: session)
            else
            {
                //  If, for some reason, the account has disappeared, we'll just create
                //  a new one.
                fallthrough
            }

            cookie = changed

        case .status:
            cookie = try await server.db.account.users.update(
                account: .machine(0),
                with: session)
        }

        let page:Site.Admin.Slaves = .init(cookie: "\(cookie)")
        return .ok(page.resource(assets: server.assets))
    }
}
