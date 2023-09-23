import GitHubClient
import GitHubAPI
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
extension Server.Operation.Bounce:UnrestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
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
