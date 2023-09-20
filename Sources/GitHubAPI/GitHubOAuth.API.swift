extension GitHubOAuth
{
    @frozen public
    struct API
    {
        public
        let agent:String
        public
        let oauth:GitHubOAuth?

        @inlinable internal
        init(agent:String, oauth:GitHubOAuth?)
        {
            self.agent = agent
            self.oauth = oauth
        }
    }
}
