import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct RegisterOperation:Sendable
    {
        let token:String
        let from:String

        init(token:String, from:String = "\(Unidoc.ServerRoot.account)")
        {
            self.token = token
            self.from = from
        }
    }
}
extension Unidoc.RegisterOperation:Unidoc.InteractiveOperation
{
    func load(from server:borrowing Unidoc.Server,
        with _:Unidoc.Credentials,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.OAuth>

        if  let integration:GitHub.Integration = server.github
        {
            github = .rest(app: integration.oauth,
                threads: server.context.threads,
                niossl: server.context.niossl,
                as: integration.agent)
        }
        else
        {
            return nil
        }

        let user:Unidoc.User = try await github.connect
        {
            let user:GitHub.User = try await $0.get(from: "/user", with: self.token)
            let orgs:[GitHub.OrganizationMembership] = try await $0.get(
                from: "/user/memberships/orgs",
                with: self.token)

            print(orgs)

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
            cookies: [Unidoc.Cookies.session: "\(secrets.session)"])
    }
}
