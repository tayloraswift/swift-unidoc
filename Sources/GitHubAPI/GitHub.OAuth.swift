extension GitHub
{
    /// The essence of a GitHub OAuth application.
    ///
    /// A `GitHub.OAuth` instance is just a ``client`` ID and ``secret``.
    ///
    /// >   Note:
    /// This type would be named `GitHub.OAuthApp`, but then ``GitHub.App`` would have to be
    /// named ``GitHub.AppApp``, and that would just be stupid.
    @frozen public
    struct OAuth:GitHubApplication
    {
        public
        let client:String
        public
        let secret:String

        @inlinable public
        init(client:String, secret:String)
        {
            self.client = client
            self.secret = secret
        }
    }
}
extension GitHub.OAuth
{
    /// The GitHub REST API.
    @inlinable public
    var api:GitHub.API<Void>
    {
        .init(agent: "swift-unidoc (by tayloraswift)", oauth: self, pat: ())
    }

    /// The GitHub GraphQL API.
    @inlinable public
    func api(pat:String) -> GitHub.API<String>
    {
        .init(agent: "swift-unidoc (by tayloraswift)", oauth: self, pat: pat)
    }
}
