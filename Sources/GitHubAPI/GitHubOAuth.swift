/// The essence of a GitHub OAuth application.
///
/// A `GitHubOAuth` instance is just a ``client`` ID and ``secret``.
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
extension GitHubOAuth
{
    /// The GitHub API.
    @inlinable public
    var api:API { .init(agent: "swift-unidoc (by tayloraswift)", oauth: self) }
}
