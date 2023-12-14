import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RedirectOutput:Equatable, Sendable
    {
        public
        let matches:[Volume.Vertex]
        public
        let volume:Volume.Metadata

        @inlinable internal
        init(matches:[Volume.Vertex], volume:Volume.Metadata)
        {
            self.matches = matches
            self.volume = volume
        }
    }
}
extension Unidoc.RedirectOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable, Sendable
    {
        case matches = "M"
        case volume = "Z"
    }
}
extension Unidoc.RedirectOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(matches: try bson[.matches].decode(), volume: try bson[.volume].decode())
    }
}
