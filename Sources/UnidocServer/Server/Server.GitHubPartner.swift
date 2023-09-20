import GitHubClient
import GitHubIntegration

extension Server
{
    struct GitHubPartner
    {
        let oauth:GitHubClient<GitHubOAuth>
        // let app:GitHubClient<GitHubApp>
        let api:GitHubClient<GitHubAPI>

        init(oauth:GitHubClient<GitHubOAuth>, api:GitHubClient<GitHubAPI>)
        {
            self.oauth = oauth
            self.api = api
        }
    }
}
