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

    let mode:ServerMode
    var tour:ServerTour

    init(
        database:Database,
        github:
        (
            oauth:GitHubClient<GitHubOAuth>,
            app:GitHubClient<GitHubApp>,
            api:GitHubClient<GitHubAPI>
        )?,
        mode:ServerMode = .secured)
    {
        self.database = database
        self.github = github

        self.tour = .init(started: .now)
        self.mode = mode
    }
}
