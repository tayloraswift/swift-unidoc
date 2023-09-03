import GitHubIntegration
import HTTPServer
import MongoDB
import UnidocDatabase

protocol GitHubOperation:Sendable
{
    func load(from github:GitHubApplication.Client,
        into database:Database,
        pool:Mongo.SessionPool,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
}
