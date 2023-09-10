import BSONDecoding
import BSONEncoding
import GitHubIntegration

extension GitHubAPI.Repo.License:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
    }
}
extension GitHubAPI.Repo.License:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), name: try bson[.name].decode())
    }
}
