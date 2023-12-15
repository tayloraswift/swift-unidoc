import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.ActivityQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let repo:[UnidocDatabase.RepoFeed.Activity]
        public
        let docs:[UnidocDatabase.DocsFeed.Activity<Unidoc.VolumeMetadata>]

        @inlinable internal
        init(
            repo:[UnidocDatabase.RepoFeed.Activity],
            docs:[UnidocDatabase.DocsFeed.Activity<Unidoc.VolumeMetadata>])
        {
            self.repo = repo
            self.docs = docs
        }
    }
}
extension Unidoc.ActivityQuery.Output:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case repo = "R"
        case docs = "D"
    }
}
extension Unidoc.ActivityQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(repo: try bson[.repo].decode(), docs: try bson[.docs].decode())
    }
}
