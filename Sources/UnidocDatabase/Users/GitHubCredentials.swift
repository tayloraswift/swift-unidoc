import BSONDecoding
import BSONEncoding
import GitHubIntegration

@frozen @usableFromInline internal
struct GitHubCredentials
{
    @usableFromInline internal
    var refresh:GitHubCredential<BSON.Millisecond>
    @usableFromInline internal
    var access:GitHubCredential<BSON.Millisecond>

    @inlinable internal
    init(
        refresh:GitHubCredential<BSON.Millisecond>,
        access:GitHubCredential<BSON.Millisecond>)
    {
        self.refresh = refresh
        self.access = access
    }
}
extension GitHubCredentials
{
    init(tokens:GitHubTokens, created:BSON.Millisecond)
    {
        self.init(
            refresh: .init(token: tokens.refresh, created: created),
            access:  .init(token: tokens.access, created: created))
    }
}
extension GitHubCredentials
{
    @usableFromInline internal
    enum CodingKey:String
    {
        case refresh = "R"
        case access = "A"
    }
}
extension GitHubCredentials:BSONDocumentEncodable
{
    @usableFromInline internal
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.refresh] = self.refresh
        bson[.access] = self.access
    }
}
extension GitHubCredentials:BSONDocumentDecodable
{
    @inlinable internal
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            refresh: try bson[.refresh].decode(),
            access:  try bson[.access].decode())
    }
}
