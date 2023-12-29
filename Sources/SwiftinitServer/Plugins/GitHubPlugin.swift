import GitHubAPI
import System

struct GitHubPlugin:Sendable
{
    let oauth:GitHub.OAuth
    let app:GitHub.App
    let pat:String

    init(oauth:GitHub.OAuth, app:GitHub.App, pat:String)
    {
        self.oauth = oauth
        self.app = app
        self.pat = pat
    }
}
extension GitHubPlugin
{
    static
    func load(secrets:FilePath) throws -> Self
    {
        .init(
            oauth: .init(
                client: "2378cacaed3ace362867",
                secret: try (secrets / "github-oauth-secret").readLine()),
            app: .init(383005,
                client: "Iv1.dba609d35c70bf57",
                secret: try (secrets / "github-app-secret").readLine()),
            pat: try (secrets / "github-pat").readLine())
    }
}
