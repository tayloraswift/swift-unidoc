import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import UnidocDB

extension Swiftinit
{
    struct LoginEndpoint:Sendable
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
extension Swiftinit.LoginEndpoint:InteractiveEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        guard let oauth:GitHubClient<GitHubOAuth> = server.plugins.github?.oauth
        else
        {
            return nil
        }

        guard case self.state? = cookies.login
        else
        {
            return .resource("Authentication failed: state mismatch", status: 400)
        }

        let registration:Swiftinit.RegistrationEndpoint
        do
        {
            let access:GitHubOAuth.Credentials = try await oauth.exchange(code: self.code)
            registration = .init(token: access.token)
        }
        catch is GitHubClient<GitHubOAuth>.AuthenticationError
        {
            return .unauthorized("Authentication failed")
        }
        catch
        {
            throw error
        }

        return try await registration.load(from: server, with: cookies)
    }
}
