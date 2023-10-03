import BSONDecoding
import MongoSchema
import UnidocSelectors
import UnidocRecords

extension ThinQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let matches:[Volume.Vertex]
        public
        let volume:Volume.Meta

        @inlinable internal
        init(matches:[Volume.Vertex], volume:Volume.Meta)
        {
            self.matches = matches
            self.volume = volume
        }
    }
}
extension ThinQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case matches = "M"
        case volume = "Z"
    }
}
extension ThinQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(matches: try bson[.matches].decode(), volume: try bson[.volume].decode())
    }
}
