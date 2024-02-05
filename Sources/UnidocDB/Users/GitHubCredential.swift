import BSON
import GitHubAPI

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
extension GitHubCredential<BSON.Millisecond>
{
    init(token:GitHub.App.Token, created:BSON.Millisecond)
    {
        self.init(expires: .init(created.value + 1000 * token.secondsRemaining),
            token: token.value)
    }
}
extension GitHubCredential
{
    enum CodingKey:String, Sendable
    {
        case expires = "E"
        case token = "T"
    }
}
extension GitHubCredential:BSONDocumentEncodable, BSONEncodable
    where Instant:BSONEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.expires] = self.expires
        bson[.token] = self.token
    }
}
extension GitHubCredential:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where Instant:BSONDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            expires: try bson[.expires].decode(),
            token: try bson[.token].decode())
    }
}
