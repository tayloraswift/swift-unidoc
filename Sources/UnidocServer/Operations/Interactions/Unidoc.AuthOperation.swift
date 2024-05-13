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
        let from:String

        init(state:String, code:String, from:String)
        {
            self.state = state
            self.code = code
            self.from = from
        }
    }
}
extension Unidoc.AuthOperation:Unidoc.InteractiveOperation
{
    func load(from server:borrowing Unidoc.Server,
        with credentials:Unidoc.Credentials,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.OAuth>
        if  let integration:GitHub.Integration = server.github
        {
            github = .auth(app: integration.oauth,
                threads: server.context.threads,
                niossl: server.context.niossl,
                as: integration.agent)
        }
        else
        {
            return nil
        }

        guard case self.state? = credentials.cookies.login
        else
        {
            return .resource("Authentication failed: state mismatch", status: 400)
        }

        let registration:Unidoc.RegisterOperation
        do
        {
            let access:GitHub.OAuth.Credentials = try await github.exchange(code: self.code)
            registration = .init(token: access.token, from: self.from)
        }
        catch is GitHub.Client<GitHub.OAuth>.AuthenticationError
        {
            return .unauthorized("Authentication failed")
        }
        catch
        {
            throw error
        }

        return try await registration.load(from: server, with: credentials, as: format)
    }
}
