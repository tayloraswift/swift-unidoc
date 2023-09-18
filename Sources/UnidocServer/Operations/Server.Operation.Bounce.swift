import GitHubClient
import GitHubIntegration
import HTTP
import UnidocPages

extension Server.Operation
{
    struct Bounce:Sendable
    {
        init()
        {
        }
    }
}
extension Server.Operation.Bounce:StatefulOperation
{
    func load(from server:ServerState,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        if  let oauth:GitHubOAuth = server.github?.oauth.app
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
