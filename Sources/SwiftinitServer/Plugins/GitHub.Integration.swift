import GitHubAPI
import System

extension GitHub
{
    struct Integration:Sendable
    {
        let active:Bool
        let oauth:GitHub.OAuth
        let app:GitHub.App
        let pat:String

        init(active:Bool, oauth:GitHub.OAuth, app:GitHub.App, pat:String)
        {
            self.active = active
            self.oauth = oauth
            self.app = app
            self.pat = pat
        }
    }
}
extension GitHub.Integration
{
    static
    func load(secrets:FilePath, active:Bool) throws -> Self
    {
        .init(
            active: active,
            oauth: .init(
                client: "2378cacaed3ace362867",
                secret: try (secrets / "github-oauth-secret").readLine()),
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
