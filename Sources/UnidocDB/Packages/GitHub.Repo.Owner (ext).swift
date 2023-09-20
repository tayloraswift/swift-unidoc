import BSONDecoding
import BSONEncoding
import GitHubAPI
import MongoQL

extension GitHub.Repo.Owner:MongoMasterCodingModel
{
}
extension GitHub.Repo.Owner:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.login] = self.login
        bson[.node] = self.node
    }
}
extension GitHub.Repo.Owner:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            login: try bson[.login].decode(),
            node: try bson[.node].decode())
    }
}
