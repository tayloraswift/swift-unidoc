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
        let from:String

        init(token:String, from:String = "\(Swiftinit.Root.account)")
        {
            self.token = token
            self.from = from
        }
    }
}
extension Swiftinit.RegistrationEndpoint:Swiftinit.InteractiveEndpoint
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
            /// r u taylor swift?
            let level:Unidoc.User.Level = user.id == 2556986 ? .administratrix : .human
            let id:Unidoc.Account = .init(type: .github, user: user.id)
            return .init(id: id,
                level: level,
                //  This will only be written to the database if the user is new.
                apiLimitLeft: server.db.policy.apiLimitPerReset,
                github: user.profile)
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let secrets:Unidoc.UserSecrets = try await server.db.users.update(user: user,
            with: session)

        return .redirect(.temporary(self.from), // meet taylor swift
            cookies: [Swiftinit.Cookies.session: "\(secrets.session)"])
    }
}
