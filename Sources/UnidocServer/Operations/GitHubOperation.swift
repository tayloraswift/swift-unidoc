import GitHubClient
import GitHubIntegration
import HTTPServer
import MongoDB
import UnidocDatabase

protocol GitHubOperation:Sendable
{
    func load(from github:GitHubClient<GitHubOAuth>,
        into database:Unidoc.Database,
        pool:Mongo.SessionPool,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
}
