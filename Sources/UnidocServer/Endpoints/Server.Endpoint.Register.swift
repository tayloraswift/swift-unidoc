import GitHubClient
import GitHubIntegration
import HTTP
import MongoDB
import UnidocDatabase
import UnidocPages

extension Server.Endpoint
{
    struct Register:Sendable
    {
        let token:String

        init(token:String)
        {
            self.token = token
        }
    }
}
extension Server.Endpoint.Register
{
    init?(parameters:__shared [(key:String, value:String)])
    {
        for case ("token", let value) in parameters
        {
            self.init(token: value)
            return
        }

        return nil
    }
}
extension Server.Endpoint.Register:StatefulOperation
{
    func load(from services:Services,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        guard let github:GitHubClient<GitHubAPI> = services.github?.api
        else
        {
            return nil
        }

        let user:GitHubAPI.User = try await github.get(from: "/user", with: self.token)
        let account:Account = .github(user: user,
            role: user.id == 2556986 ? .administrator : .human)

        let session:Mongo.Session = try await .init(from: services.database.sessions)
        let cookie:String = try await services.database.accounts.users.update(
            account: account,
            with: session)

        return .redirect(.temporary("\(Site.Admin.uri)"),
            cookies: [Server.Request.Cookies.session: cookie])
    }
}
