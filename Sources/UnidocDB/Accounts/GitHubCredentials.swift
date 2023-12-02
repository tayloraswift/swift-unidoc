import BSON
import GitHubAPI

@available(*, unavailable, message: "Not needed yet.")
struct GitHubCredentials
{
    var refresh:GitHubCredential<BSON.Millisecond>
    var access:GitHubCredential<BSON.Millisecond>

    init(
        refresh:GitHubCredential<BSON.Millisecond>,
        access:GitHubCredential<BSON.Millisecond>)
    {
        self.refresh = refresh
        self.access = access
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials
{
    init(tokens:GitHubApp.Credentials, created:BSON.Millisecond)
    {
        self.init(
            refresh: .init(token: tokens.refresh, created: created),
            access:  .init(token: tokens.access, created: created))
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials
{
    enum CodingKey:String, Sendable
    {
        case refresh = "R"
        case access = "A"
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.refresh] = self.refresh
        bson[.access] = self.access
    }
}
@available(*, unavailable, message: "Not needed yet.")
extension GitHubCredentials:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            refresh: try bson[.refresh].decode(),
            access:  try bson[.access].decode())
    }
}
