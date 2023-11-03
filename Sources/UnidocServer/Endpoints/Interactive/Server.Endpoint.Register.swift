import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import UnidocDB
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
extension Server.Endpoint.Register:InteractiveEndpoint
{
    func load(from server:Server,
        with _:Server.Cookies) async throws -> HTTP.ServerResponse?
    {
        guard let github:GitHubClient<GitHub.API> = server.github?.api
        else
        {
            return nil
        }

        let user:GitHub.User = try await github.connect
        {
            try await $0.get(from: "/user", with: self.token)
        }
        let account:Account = .github(user: user,
            //  Are you a mighty It Girl?
            role: user.id == 2556986 ? .administrator : .human)

        let db:Server.DB = server.db

        let session:Mongo.Session = try await .init(from: db.sessions)
        let cookie:Account.Cookie = try await db.account.users.update(
            account: account,
            with: session)

        return .redirect(.temporary("\(Site.Admin.uri)"),
            cookies: [Server.Cookies.session: "\(cookie)"])
    }
}
