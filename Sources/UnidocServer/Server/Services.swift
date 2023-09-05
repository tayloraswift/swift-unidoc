import GitHubClient
import GitHubIntegration

struct Services
{
    let database:Database
    let github:
    (
        oauth:GitHubClient<GitHubOAuth>,
        app:GitHubClient<GitHubApp>,
        api:GitHubClient<GitHubAPI>
    )?

    init(
        database:Database,
        github:
        (
            oauth:GitHubClient<GitHubOAuth>,
            app:GitHubClient<GitHubApp>,
            api:GitHubClient<GitHubAPI>
        )?)
    {
        self.database = database
        self.github = github
    }
}
