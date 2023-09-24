import MongoDB
import HTTP
import UnidocDB
import UnidocPages

protocol RestrictedOperation:InteractiveOperation
{
    static
    func admit(_ role:Account.Role) -> Bool

    func load(from state:Server.State) async throws -> ServerResponse?
}
extension RestrictedOperation
{
    static
    func admit(_ role:Account.Role) -> Bool
    {
        role == .administrator
    }

    func load(from server:Server.State,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
    {
        if  case .secured = server.mode
        {
            guard let cookie:String = cookies.session
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
                return .forbidden(.init(
                    content: .string("Regrettably, you are not a mighty It Girl."),
                    type: .text(.plain, charset: .utf8)))
            }
        }

        return try await self.load(from: server)
    }
}
