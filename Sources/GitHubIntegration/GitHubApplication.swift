@frozen public
struct GitHubApplication:Identifiable, Equatable, Hashable, Sendable
{
    public
    let id:Int

    public
    let client:String
    public
    let secret:String

    @inlinable public
    init(_ id:Int, client:String, secret:String)
    {
        self.id = id
        self.client = client
        self.secret = secret
    }
}
