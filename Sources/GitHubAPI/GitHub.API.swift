extension GitHub.OAuth
{
    @available(*, deprecated, renamed: "GitHub.API")
    public
    typealias API = GitHub.API
}

extension GitHub
{
    @frozen public
    struct API<PAT>:Sendable where PAT:Sendable
    {
        public
        let agent:String
        public
        let oauth:GitHub.OAuth
        public
        let pat:PAT

        @inlinable internal
        init(agent:String, oauth:GitHub.OAuth, pat:PAT)
        {
            self.agent = agent
            self.oauth = oauth
            self.pat = pat
        }
    }
}
