/// The essence of a GitHub OAuth application.
@frozen public
struct GitHubOAuth:GitHubApplication
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
