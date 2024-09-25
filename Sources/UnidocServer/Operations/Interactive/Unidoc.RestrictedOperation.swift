import GitHubAPI
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords
import UnidocRender

extension Unidoc
{
    /// An endpoint that requires authentication, and possibly authorization.
    public
    protocol RestrictedOperation:InteractiveOperation
    {
        mutating
        func admit(user:Unidoc.UserRights) -> Bool

        /// Obtains the response for this endpoint. The provided session is sequentially
        /// consistent with any authentication that took place before calling this witness.
        consuming
        func load(from server:Server,
            db database:Unidoc.DB,
            as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
extension Unidoc.RestrictedOperation
{
    public consuming
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        let db:Unidoc.DB

        switch context.server.db.policy.security
        {
        case .ignored:
            db = try await context.server.db.session()
            //  Yes, we need to call this, even though we ignore the result.
            let _:Bool = self.admit(user: .init(level: .administratrix))

        case .enforced:
            let user:Unidoc.UserSession

            switch context.request.authorization
            {
            case .invalid(let error):
                return .unauthorized("\(error)\n")

            case .web(nil, _):
                guard
                let oauth:GitHub.OAuth = context.server.github?.oauth
                else
                {
                    return .error("""
                        Server is running in secure mode with no OAuth capability!\n
                        """)
                }

                let login:Unidoc.LoginPage = .init(client: oauth.client,
                    flow: .sso,
                    from: context.request.uri)
                return .ok(login.resource(format: context.format))

            case .web(let session?, _):
                user = .web(session)

            case .api(let session):
                user = .api(session)
            }

            db = try await context.server.db.session()

            guard
            let rights:Unidoc.UserRights = try await db.users.validate(user: user)
            else
            {
                if  case .web = context.request.authorization
                {
                    return .unauthorized("Expired session!\n")
                }
                else
                {
                    return .unauthorized("Expired or nonexistent API key!\n")
                }
            }

            //  We ban this here, so that we can conditionally enforce permissions later by
            //  checking if the user is human.
            if  case .guest = rights.level
            {
                return .forbidden("""
                    It looks like you are somehow logged in as an organization.\n
                    """)
            }

            guard self.admit(user: rights)
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.\n")
            }
        }

        return try await self.load(from: context.server, db: db, as: context.format)
    }
}
