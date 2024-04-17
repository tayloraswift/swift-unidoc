import GitHubAPI
import GitHubClient
import HTTP
import SwiftinitPages

extension Unidoc
{
    struct LoginOperation:Sendable
    {
        let path:String

        init(from path:String = "\(ServerRoot.account)")
        {
            self.path = path
        }
    }
}
extension Unidoc.LoginOperation:Unidoc.PublicOperation
{
    func load(from server:borrowing Unidoc.Server,
        as _:Unidoc.RenderFormat) -> HTTP.ServerResponse?
    {
        if  let oauth:GitHub.OAuth = server.github?.oauth
        {
            let page:Unidoc.LoginPage = .init(oauth: oauth, from: self.path)
            return .ok(page.resource(format: server.format))
        }
        else
        {
            return nil
        }
    }
}
