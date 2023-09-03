import GitHubIntegration
import HTTPServer
import MongoDB
import UnidocDatabase
import UnidocPages

//  visit: https://github.com/login/oauth/authorize?client_id=Iv1.dba609d35c70bf57&scope=repo
extension LoginOperation
{
    struct Bounce:Sendable
    {
        init()
        {
        }
    }
}
extension LoginOperation.Bounce:GitHubOperation
{
    func load(from github:GitHubApplication.Client,
        into _:Database,
        pool _:Mongo.SessionPool,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        let page:Site.Login = .init(app: github.app)
        return .resource(page.rendered())
    }
}
