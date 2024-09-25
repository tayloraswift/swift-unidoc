import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct VertexOutput:Sendable
    {
        public
        let principal:PrincipalOutput
        public
        let canonical:AnyVertex?
        public
        let vertices:[AnyVertex]
        public
        let volumes:[VolumeMetadata]
        public
        let packages:[PackageMetadata]

        @inlinable public
        init(principal:PrincipalOutput,
            canonical:AnyVertex?,
            vertices:[AnyVertex],
            volumes:[VolumeMetadata],
            packages:[PackageMetadata])
        {
            self.principal = principal
            self.canonical = canonical
            self.vertices = vertices
            self.volumes = volumes
            self.packages = packages
        }
    }
}
extension Unidoc.VertexOutput:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case principal
        case canonical
        case vertices
        case volumes
        case packages
    }
}
extension Unidoc.VertexOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            principal: try bson[.principal].decode(),
            canonical: try bson[.canonical]?.decode(),
            vertices: try bson[.vertices].decode(),
            volumes: try bson[.volumes].decode(),
            packages: try bson[.packages].decode())
    }
}
