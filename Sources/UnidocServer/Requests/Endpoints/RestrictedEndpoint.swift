import MongoDB
import HTTP
import UnidocDB
import UnidocPages

protocol RestrictedEndpoint:InteractiveEndpoint
{
    static
    func admit(_ role:Account.Role) -> Bool

    func load(from state:Server.InteractiveState) async throws -> ServerResponse?
}
extension RestrictedEndpoint
{
    static
    func admit(_ role:Account.Role) -> Bool
    {
        role == .administrator
    }

    func load(from server:Server.InteractiveState,
        with cookies:Server.Cookies) async throws -> ServerResponse?
    {
        if  server.mode.secured
        {
            guard
            let cookie:Account.Cookie = cookies.session
            else
            {
                return .redirect(.temporary("\(Site.Login.uri)"))
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)
            let role:Account.Role? = try await server.db.account.users.validate(
                cookie: cookie,
                with: session)

            guard case true? = role.map(Self.admit(_:))
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.")
            }
        }

        return try await self.load(from: server)
    }
}
