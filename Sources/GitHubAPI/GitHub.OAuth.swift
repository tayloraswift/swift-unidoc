extension GitHub
{
    /// The essence of a GitHub OAuth application.
    ///
    /// A `GitHub.OAuth` instance is just a ``client`` ID and ``secret``.
    ///
    /// >   Note:
    /// This type would be named `GitHub.OAuthApp`, but then ``GitHub.App`` would have to be
    /// named `GitHub.AppApp`, and that would just be stupid.
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
