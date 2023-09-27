import HTTP
import MongoDB
import UnidocDB

protocol ProceduralEndpoint:Sendable
{
    func perform(on server:Server.ProceduralState) async throws -> ServerResponse
}
extension ProceduralEndpoint
{
    func perform(on server:Server.ProceduralState,
        with cookies:Server.Cookies) async throws -> ServerResponse
    {
        if  case .secured = server.mode
        {
            guard
            let cookie:Account.Cookie = cookies.session
            else
            {
                return .unauthorized("")
            }

            let mongo:Mongo.Session = try await .init(from: server.db.sessions)

            switch try await server.db.account.users.validate(cookie: cookie, with: mongo)
            {
            case .administrator?, .machine?:
                break

            case .human?, nil:
                return .forbidden("")
            }
        }

        return try await self.perform(on: server)
    }
}
