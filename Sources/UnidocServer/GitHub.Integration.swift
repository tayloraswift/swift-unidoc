import GitHubAPI
import System

extension GitHub
{
    @frozen public
    struct Integration:Sendable
    {
        public
        let oauth:OAuth
        public
        let app:App
        public
        let pat:PersonalAccessToken

        @inlinable public
        init(oauth:OAuth, app:App, pat:PersonalAccessToken)
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
    var agent:String { "unidoc (by tayloraswift)" }
}
