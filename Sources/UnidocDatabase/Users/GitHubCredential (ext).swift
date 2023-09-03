import BSONDecoding
import BSONEncoding
import GitHubIntegration

extension GitHubCredential<BSON.Millisecond>
{
    init(token:GitHubToken, created:BSON.Millisecond)
    {
        self.init(expires: .init(created.value + 1000 * token.secondsRemaining),
            token: token.value)
    }
}
extension GitHubCredential
{
    public
    enum CodingKey:String
    {
        case expires = "E"
        case token = "T"
    }
}
extension GitHubCredential:BSONDocumentEncodable, BSONEncodable
    where Instant:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.expires] = self.expires
        bson[.token] = self.token
    }
}
extension GitHubCredential:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where Instant:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            expires: try bson[.expires].decode(),
            token: try bson[.token].decode())
    }
}
