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
            let page:Site.Login = .init(app: oauth)
            return .ok(page.resource(format: .init(assets: server.assets)))
        }
        else
        {
            return nil
        }
    }
}
