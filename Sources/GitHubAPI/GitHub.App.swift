extension GitHub
{
    /// The essence of a GitHub App, which is a type of GitHub application.
    @frozen public
    struct App:GitHubApplication, Identifiable
    {
        /// The app id number. This is different from the client id.
        public
        let id:Int32?

        public
        let client:String
        public
        let secret:String

        @inlinable public
        init(_ id:Int32?, client:String, secret:String)
        {
            self.id = id
            self.client = client
            self.secret = secret
        }
    }
}
