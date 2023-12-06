import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidex.EditionsQuery
{
    @frozen public
    struct Facet:Equatable, Sendable
    {
        public
        var edition:Unidex.Edition
        public
        var graphs:Graphs?
        public
        var volume:Volume.Metadata?

        @inlinable public
        init(edition:Unidex.Edition, graphs:Graphs? = nil, volume:Volume.Metadata? = nil)
        {
            self.edition = edition
            self.graphs = graphs
            self.volume = volume
        }
    }
}
extension Unidex.EditionsQuery.Facet:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case edition
        case graphs
        case volume
    }
}
extension Unidex.EditionsQuery.Facet:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            edition: try bson[.edition].decode(),
            graphs: try bson[.graphs]?.decode(),
            volume: try bson[.volume]?.decode())
    }
}
