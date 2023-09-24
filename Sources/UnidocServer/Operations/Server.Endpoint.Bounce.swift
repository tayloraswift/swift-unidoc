import GitHubClient
import GitHubAPI
import HTTP
import UnidocPages

extension Server.Endpoint
{
    struct Bounce:Sendable
    {
        init()
        {
        }
    }
}
extension Server.Endpoint.Bounce:PublicEndpoint
{
    func load(from server:Server.InteractiveState) async throws -> ServerResponse?
    {
        if  let oauth:GitHubOAuth = server.github?.oauth.app
        {
            let page:Site.Login = .init(app: oauth)
            return .ok(page.resource())
        }
        else
        {
            return nil
        }
    }
}
