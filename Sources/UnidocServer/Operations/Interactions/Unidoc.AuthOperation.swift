import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import UnidocDB

extension Unidoc
{
    struct AuthOperation:Sendable
    {
        let state:String
        let code:String

        let flow:LoginFlow
        let from:String

        init(state:String, code:String, flow:LoginFlow, from:String)
        {
            self.state = state
            self.code = code
            self.flow = flow
            self.from = from
        }
    }
}
extension Unidoc.AuthOperation:Unidoc.InteractiveOperation
{
    func load(from server:Unidoc.Server,
        with state:Unidoc.UserSessionState) async throws -> HTTP.ServerResponse?
    {
        guard case .web(_, login: self.state?) = state.authorization
        else
        {
            return .resource("Authentication failed: state mismatch", status: 400)
        }

        guard
        let integration:GitHub.Integration = server.github
        else
        {
            return nil
        }

        let client:GitHub.Client<GitHub.OAuth> = .auth(app: integration.oauth,
                threads: server.context.threads,
                niossl: server.context.niossl,
                as: integration.agent)

        let access:GitHub.OAuth.Credentials
        do
        {
            access = try await client.exchange(code: self.code)
        }
        catch is GitHub.Client<GitHub.OAuth>.AuthenticationError
        {
            return .unauthorized("Authentication failed")
        }

        let operation:Unidoc.UserIndexOperation = .init(token: access.token,
            flow: self.flow,
            from: self.from)

        //  We must not reuse the same client, as this step must be performed against
        //  `api.github.com` and not `github.com`.
        return try await operation.perform(on: server)
    }
}
