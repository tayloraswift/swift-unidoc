@frozen public
struct GitHubCredential<Instant>:Sendable where Instant:Sendable
{
    public
    let expires:Instant
    public
    let token:String

    @inlinable public
    init(expires:Instant, token:String)
    {
        self.expires = expires
        self.token = token
    }
}
extension GitHubCredential:Equatable where Instant:Equatable
{
}
extension GitHubCredential:Hashable where Instant:Hashable
{
}
