import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct VertexOutput:Sendable
    {
        public
        let principal:PrincipalOutput?
        public
        let vertices:[Unidoc.AnyVertex]
        public
        let volumes:[Unidoc.VolumeMetadata]

        @inlinable public
        init(principal:PrincipalOutput?,
            vertices:[Unidoc.AnyVertex],
            volumes:[Unidoc.VolumeMetadata])
        {
            self.principal = principal
            self.vertices = vertices
            self.volumes = volumes
        }
    }
}
extension Unidoc.VertexOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case principal
        case vertices
        case volumes
    }
}
extension Unidoc.VertexOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            principal: try bson[.principal]?.decode(),
            vertices: try bson[.vertices].decode(),
            volumes: try bson[.volumes].decode())
    }
}
