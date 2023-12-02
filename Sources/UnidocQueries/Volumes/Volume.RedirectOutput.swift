import BSON
import MongoSchema
import UnidocSelectors
import UnidocRecords

extension Volume
{
    @frozen public
    struct RedirectOutput:Equatable, Sendable
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
extension Volume.RedirectOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable, Sendable
    {
        case matches = "M"
        case volume = "Z"
    }
}
extension Volume.RedirectOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(matches: try bson[.matches].decode(), volume: try bson[.volume].decode())
    }
}
