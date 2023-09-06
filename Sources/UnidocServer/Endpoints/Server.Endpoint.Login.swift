import GitHubClient
import GitHubIntegration
import HTTP
import MongoDB
import UnidocDatabase

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
extension Server.Endpoint.Login
{
    init?(parameters:__shared [(key:String, value:String)])
    {
        var state:String?
        var code:String?

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "state":   state = value
            case "code":    code = value
            case _:         continue
            }
        }

        if  let state:String,
            let code:String
        {
            self.init(state: state, code: code)
        }
        else
        {
            return nil
        }
    }
}
extension Server.Endpoint.Login:StatefulOperation
{
    func load(from services:Services,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
    {
        guard let oauth:GitHubClient<GitHubOAuth> = services.github?.oauth
        else
        {
            return nil
        }

        guard case self.state? = cookies.login
        else
        {
            return .resource(.init(.one(canonical: nil),
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
            return .resource(.init(.one(canonical: nil),
                content: .string("Authentication failed"),
                type: .text(.plain, charset: .utf8)))
        }
        catch
        {
            throw error
        }

        return try await registration.load(from: services, with: cookies)
    }
}
