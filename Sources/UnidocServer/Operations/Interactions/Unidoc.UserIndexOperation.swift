import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// `UserIndexOperation` is rarely used on its own; its main purpose is to assist the
    /// ``AuthOperation`` type in registering a new user. It is a standalone operation to aid
    /// debugging and testing.
    struct UserIndexOperation:Sendable
    {
        let token:String
        let flow:LoginFlow
        let from:String

        init(token:String, flow:LoginFlow, from:String = "\(Unidoc.ServerRoot.account)")
        {
            self.token = token
            self.flow = flow
            self.from = from
        }
    }
}
extension Unidoc.UserIndexOperation:Unidoc.InteractiveOperation
{
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        try await self.perform(on: context.server)
    }
}
extension Unidoc.UserIndexOperation
{
    func perform(on server:Unidoc.Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let integration:any GitHub.Integration = server.github
        else
        {
            return nil
        }

        let restAPI:GitHub.Client<GitHub.OAuth> = .rest(app: integration.oauth,
            niossl: server.clientIdentity,
            on: .singleton,
            as: integration.agent)

        let cookies:[(String, HTTP.CookieValue)]

        switch self.flow
        {
        case .sso:
            let user:Unidoc.User = try await restAPI.connect
            {
                let user:GitHub.User = try await $0.get(from: "/user", with: .token(self.token))
                return .init(github: user, initialLimit: server.db.settings.apiLimitPerReset)
            }

            let db:Unidoc.DB = try await server.db.session()
            let secrets:Unidoc.UserSecrets = try await db.users.update(user: user)

            guard
            let web:Unidoc.UserSession.Web = secrets.web
            else
            {
                return .forbidden("""
                    It looks like you have somehow logged in as an anonymous user.\n
                    """)
            }

            let cookie:HTTP.CookieValue = .init("\(web)")
            {
                $0.httpOnly = true
                $0.secure = true
                $0.maxAge = 90 * 86400
                $0.path = "/"
                $0.sameSite = .lax
            }

            cookies = [(Unidoc.Cookie.loginSession, cookie)]

        case .sync:
            cookies = []

            let memberships:[GitHub.OrganizationMembership] = try await restAPI.connect
            {
                try await $0.get(from: "/user/memberships/orgs", with: .token(self.token))
            }

            guard
            let current:GitHub.Repo.Owner = memberships.first?.user
            else
            {
                //  If the user is not a member of any organizations, we cannot sync their
                //  permissions. This means their existing permissions won’t be revoked, but we
                //  really shouldn’t be relying on users to revoke their own access anyway.
                break
            }

            let users:[Unidoc.User] = memberships.compactMap
            {
                guard case .active = $0.state
                else
                {
                    return nil
                }

                return .init(id: .init(type: .github, user: $0.organization.id),
                    level: .guest,
                    symbol: $0.organization.login)
            }

            let db:Unidoc.DB = try await server.db.session()
            let _:Mongo.Updates<Unidoc.Account> = try await db.users.update(users: users)

            guard
            let _:Bool = try await db.users.update(access: users.map(\.id),
                user: .init(type: .github, user: current.id))
            else
            {
                return .resource("No such user", status: 404)
            }
        }

        return .redirect(.temporary(self.from), cookies: cookies)
    }
}
