/// The essence of a GitHub App, which is a type of GitHub application.
@frozen public
struct GitHubApp:GitHubApplication, Identifiable
{
    /// The app id number. This is different from the client id.
    public
    let id:Int?

    public
    let client:String
    public
    let secret:String

    @inlinable public
    init(_ id:Int?, client:String, secret:String)
    {
        self.id = id
        self.client = client
        self.secret = secret
    }
}
