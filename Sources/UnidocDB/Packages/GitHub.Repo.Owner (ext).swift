import BSON
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
        bson[.login] = self.login
    }
}
extension GitHub.Repo.Owner:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(login: try bson[.login].decode())
    }
}
