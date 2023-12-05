import BSON
import MongoQL
import UnidocRecords
import UnidocSelectors

extension Volume
{
    @frozen public
    struct LookupOutput<T>:Equatable, Sendable
    {
        public
        let principal:PrincipalOutput?
        public
        let vertices:[Volume.Vertex]
        public
        let volumes:[Volume.Metadata]

        @inlinable public
        init(principal:PrincipalOutput?,
            vertices:[Volume.Vertex],
            volumes:[Volume.Metadata])
        {
            self.principal = principal
            self.vertices = vertices
            self.volumes = volumes
        }
    }
}
extension Volume.LookupOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case principal
        case vertices
        case volumes
    }
}
extension Volume.LookupOutput:BSONDocumentDecodable
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
