import BSONDecoding
import MongoSchema
import UnidocRecords
import UnidocSelectors

extension WideQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let principal:Principal?
        public
        let vertices:[Volume.Vertex]
        public
        let volumes:[Volume.Meta]

        @inlinable public
        init(principal:Principal?,
            vertices:[Volume.Vertex],
            volumes:[Volume.Meta])
        {
            self.principal = principal
            self.vertices = vertices
            self.volumes = volumes
        }
    }
}
extension WideQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case principal
        case vertices
        case volumes
    }
}
extension WideQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal]?.decode(),
            vertices: try bson[.vertices].decode(),
            volumes: try bson[.volumes].decode())
    }
}
