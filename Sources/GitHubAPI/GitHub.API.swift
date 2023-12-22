extension GitHub.OAuth
{
    @available(*, deprecated, renamed: "GitHub.API")
    public
    typealias API = GitHub.API
}

extension GitHub
{
    @frozen public
    struct API
    {
        public
        let agent:String
        public
        let oauth:GitHub.OAuth

        @inlinable internal
        init(agent:String, oauth:GitHub.OAuth)
        {
            self.agent = agent
            self.oauth = oauth
        }
    }
}
