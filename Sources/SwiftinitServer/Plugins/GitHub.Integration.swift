import GitHubAPI
import System

extension GitHub
{
    struct Integration:Sendable
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
}
extension GitHub.Integration
{
    static
    func load(secrets:FilePath, localhost:Bool = false) throws -> Self
    {
        let oauth:GitHub.OAuth
        if  localhost
        {
            oauth = .init(
                client: try (secrets / "localhost" / "github-oauth-client").readLine(),
                secret: try (secrets / "localhost" / "github-oauth-secret").readLine())
        }
        else
        {
            oauth = .init(
                client: "2378cacaed3ace362867",
                secret: try (secrets / "github-oauth-secret").readLine())
        }

        return .init(oauth: oauth,
            app: .init(383005,
                client: "Iv1.dba609d35c70bf57",
                secret: try (secrets / "github-app-secret").readLine()),
            pat: try (secrets / "github-pat").readLine())
    }
}
extension GitHub.Integration
{
    var api:GitHub.API<String> { self.oauth.api(pat: self.pat) }
}
