import MongoDB
import HTTP
import UnidocDatabase
import UnidocPages

protocol RestrictedOperation:StatefulOperation
{
    static
    func admit(_ role:Account.Role) -> Bool

    func load(from services:Services) async throws -> ServerResponse?
}
extension RestrictedOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.restricted
    }
}
extension RestrictedOperation
{
    static
    func admit(_ role:Account.Role) -> Bool
    {
        role == .administrator
    }

    func load(from services:Services,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
    {
        if  case .secured = services.mode
        {
            guard let cookie:String = cookies.session
            else
            {
                return .redirect(.temporary("\(Site.Login.uri)"))
            }

            let session:Mongo.Session = try await .init(from: services.database.sessions)
            let role:Account.Role? = try await services.database.account.users.validate(
                cookie: cookie,
                with: session)

            guard case true? = role.map(Self.admit(_:))
            else
            {
                return .resource(.init(.forbidden,
                    content: .string("Regrettably, you are not a mighty It Girl."),
                    type: .text(.plain, charset: .utf8)))
            }
        }

        return try await self.load(from: services)
    }
}