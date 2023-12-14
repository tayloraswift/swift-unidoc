import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RedirectOutput:Equatable, Sendable
    {
        public
        let matches:[Unidoc.Vertex]
        public
        let volume:Unidoc.VolumeMetadata

        @inlinable internal
        init(matches:[Unidoc.Vertex], volume:Unidoc.VolumeMetadata)
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
