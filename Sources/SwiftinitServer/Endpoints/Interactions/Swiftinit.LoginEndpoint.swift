import GitHubAPI
import GitHubClient
import HTTP
import SwiftinitPages

extension Swiftinit
{
    struct LoginEndpoint:Sendable
    {
        let path:String

        init(from path:String = "\(Swiftinit.Root.account)")
        {
            self.path = path
        }
    }
}
extension Swiftinit.LoginEndpoint:Swiftinit.PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        as _:Unidoc.RenderFormat) -> HTTP.ServerResponse?
    {
        if  let oauth:GitHub.OAuth = server.github?.oauth
        {
            let page:Swiftinit.LoginPage = .init(oauth: oauth, from: self.path)
            return .ok(page.resource(format: server.format))
        }
        else
        {
            return nil
        }
    }
}
