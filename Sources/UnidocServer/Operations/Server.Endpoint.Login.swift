import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import UnidocDB

extension Server.Endpoint
{
    struct Login:Sendable
    {
        let state:String
        let code:String

        init(state:String, code:String)
        {
            self.state = state
            self.code = code
        }
    }
}
extension Server.Endpoint.Login:InteractiveEndpoint
{
    func load(from server:Server.InteractiveState,
        with cookies:Server.Cookies) async throws -> ServerResponse?
    {
        guard let oauth:GitHubClient<GitHubOAuth> = server.github?.oauth
        else
        {
            return nil
        }

        guard case self.state? = cookies.login
        else
        {
            return .ok(.init(
                content: .string("Authentication failed: state mismatch"),
                type: .text(.plain, charset: .utf8)))
        }

        let registration:Server.Endpoint.Register
        do
        {
            let access:GitHubOAuth.Credentials = try await oauth.exchange(code: self.code)
            registration = .init(token: access.token)
        }
        catch is GitHubClient<GitHubOAuth>.AuthenticationError
        {
            return .ok(.init(
                content: .string("Authentication failed"),
                type: .text(.plain, charset: .utf8)))
        }
        catch
        {
            throw error
        }

        return try await registration.load(from: server, with: cookies)
    }
}
