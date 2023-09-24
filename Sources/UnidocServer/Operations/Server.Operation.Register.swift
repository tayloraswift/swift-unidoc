import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import UnidocDB
import UnidocPages

extension Server.Operation
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
extension Server.Operation.Register:InteractiveOperation
{
    func load(from server:Server.State,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        guard let github:GitHubClient<GitHubOAuth.API> = server.github?.api
        else
        {
            return nil
        }

        let user:GitHub.User = try await github.get(from: "/user", with: self.token)
        let account:Account = .github(user: user,
            //  Are you a mighty It Girl?
            role: user.id == 2556986 ? .administrator : .human)

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let cookie:String = try await server.db.account.users.update(
            account: account,
            with: session)

        return .redirect(.temporary("\(Site.Admin.uri)"),
            cookies: [Server.Request.Cookies.session: cookie])
    }
}
