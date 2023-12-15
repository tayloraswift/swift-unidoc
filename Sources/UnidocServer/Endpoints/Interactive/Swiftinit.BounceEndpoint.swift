import GitHubClient
import GitHubAPI
import HTTP
import UnidocPages

extension Swiftinit
{
    struct BounceEndpoint:Sendable
    {
        init()
        {
        }
    }
}
extension Swiftinit.BounceEndpoint:PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server) -> HTTP.ServerResponse?
    {
        if  let oauth:GitHubOAuth = server.plugins.github?.plugin.oauth
        {
            let page:Swiftinit.LoginPage = .init(app: oauth)
            return .ok(page.resource(format: server.format))
        }
        else
        {
            return nil
        }
    }
}
