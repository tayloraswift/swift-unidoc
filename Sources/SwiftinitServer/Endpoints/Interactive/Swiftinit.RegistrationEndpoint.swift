import GitHubAPI
import GitHubClient
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
        with _:Swiftinit.Cookies,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.API<Void>>

        if  let api:GitHub.API<Void> = server.github?.oauth.api
        {
            github = .rest(api: api,
                threads: server.context.threads,
                niossl: server.context.niossl)
        }
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
