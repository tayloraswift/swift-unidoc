import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidex
{
    @frozen public
    struct EditionOutput:Equatable, Sendable
    {
        public
        var edition:Unidoc.EditionMetadata

        public
        var volume:Volume.Metadata?
        public
        var graph:Graph?

        @inlinable public
        init(edition:Unidoc.EditionMetadata,
            volume:Volume.Metadata?,
            graph:Graph?)
        {
            self.edition = edition
            self.volume = volume
            self.graph = graph
        }
    }
}
extension Unidex.EditionOutput:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case edition
        case volume
        case graph
    }
}
extension Unidex.EditionOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(edition: try bson[.edition].decode(),
            volume: try bson[.volume]?.decode(),
            graph: try bson[.graph]?.decode())
    }
}
