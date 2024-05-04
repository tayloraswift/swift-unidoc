import GitHubAPI
import System

extension GitHub
{
    @frozen public
    struct Integration:Sendable
    {
        public
        let oauth:GitHub.OAuth
        public
        let app:GitHub.App
        public
        let pat:String

        @inlinable public
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
    @inlinable public
    var api:GitHub.API<String> { self.oauth.api(pat: self.pat) }
}
