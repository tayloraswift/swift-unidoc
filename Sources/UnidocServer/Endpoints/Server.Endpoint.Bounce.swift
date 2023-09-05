import GitHubClient
import GitHubIntegration
import HTTPServer
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
extension Server.Endpoint.Bounce:StatefulOperation
{
    func load(from services:Services,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        if  let oauth:GitHubOAuth = services.github?.oauth.app
        {
            let page:Site.Login = .init(app: oauth)
            return .resource(page.rendered())
        }
        else
        {
            return nil
        }
    }
}
