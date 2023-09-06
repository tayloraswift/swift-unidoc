import GitHubClient
import GitHubIntegration
import UnidocPages

struct Services
{
    let database:Database
    let github:
    (
        oauth:GitHubClient<GitHubOAuth>,
        app:GitHubClient<GitHubApp>,
        api:GitHubClient<GitHubAPI>
    )?

    var tour:Site.Admin.Tour

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

        self.tour = .init(started: .now)
    }
}
