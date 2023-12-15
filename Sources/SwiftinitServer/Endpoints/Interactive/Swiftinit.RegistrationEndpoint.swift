import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct RegistrationEndpoint:Sendable
    {
        let token:String

        init(token:String)
        {
            self.token = token
        }
    }
}
extension Swiftinit.RegistrationEndpoint:InteractiveEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with _:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        guard let github:GitHubClient<GitHub.API> = server.plugins.github?.api
        else
        {
            return nil
        }

        let user:Unidoc.User = try await github.connect
        {
            let user:GitHub.User = try await $0.get(from: "/user", with: self.token)
            return .init(account: .github(user),
                level: user.id == 2556986 ? .administratrix : .human)
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let cookie:Unidoc.Cookie = try await server.db.users.update(user: user,
            with: session)

        return .redirect(.temporary("\(Swiftinit.Admin.uri)"),
            cookies: [Swiftinit.Cookies.session: "\(cookie)"])
    }
}
