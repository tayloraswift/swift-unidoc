import GitHubClient
import GitHubAPI

extension Server
{
    struct GitHubPartner
    {
        let oauth:GitHubClient<GitHubOAuth>
        // let app:GitHubClient<GitHubApp>
        let api:GitHubClient<GitHubOAuth.API>

        init(oauth:GitHubClient<GitHubOAuth>, api:GitHubClient<GitHubOAuth.API>)
        {
            self.oauth = oauth
            self.api = api
        }
    }
}
