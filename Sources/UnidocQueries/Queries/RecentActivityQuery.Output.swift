import BSONDecoding
import MongoQL
import UnidocDB
import UnidocRecords

extension RecentActivityQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let repo:[UnidocDatabase.RepoActivity]
        public
        let docs:[UnidocDatabase.DocsActivity<Volume.Meta>]

        @inlinable internal
        init(
            repo:[UnidocDatabase.RepoActivity],
            docs:[UnidocDatabase.DocsActivity<Volume.Meta>])
        {
            self.repo = repo
            self.docs = docs
        }
    }
}
extension RecentActivityQuery.Output:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case repo = "R"
        case docs = "D"
    }
}
extension RecentActivityQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(repo: try bson[.repo].decode(), docs: try bson[.docs].decode())
    }
}
