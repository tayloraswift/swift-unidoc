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
    func load(from server:borrowing Unidoc.Server,
        with _:Unidoc.UserSessionState,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.perform(on: server)
    }
}
extension Unidoc.UserIndexOperation
{
    func perform(on server:borrowing Unidoc.Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let integration:GitHub.Integration = server.github
        else
        {
            return nil
        }

        let restAPI:GitHub.Client<GitHub.OAuth> = .rest(app: integration.oauth,
            threads: server.context.threads,
            niossl: server.context.niossl,
            as: integration.agent)

        let cookies:KeyValuePairs<String, String>

        switch self.flow
        {
        case .sso:
            let user:Unidoc.User = try await restAPI.connect
            {
                let user:GitHub.User = try await $0.get(from: "/user", with: .token(self.token))
                return .github(user, initialLimit: server.db.policy.apiLimitPerReset)
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)
            let secrets:Unidoc.UserSecrets = try await server.db.users.update(user: user,
                with: session)

            cookies = [Unidoc.Cookie.session: "\(secrets.web)"]

        case .sync:
            cookies = [:]

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

            let session:Mongo.Session = try await .init(from: server.db.sessions)
            let _:Mongo.Updates<Unidoc.Account> = try await server.db.users.update(users: users,
                with: session)

            guard
            let _:Bool = try await server.db.users.update(access: users.map(\.id),
                user: .init(type: .github, user: current.id),
                with: session)
            else
            {
                return .resource("No such user", status: 404)
            }
        }

        return .redirect(.temporary(self.from), cookies: cookies)
    }
}
