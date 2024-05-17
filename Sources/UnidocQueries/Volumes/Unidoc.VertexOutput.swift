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
        let principal:PrincipalOutput?
        public
        let canonical:Unidoc.AnyVertex?
        public
        let vertices:[Unidoc.AnyVertex]
        public
        let volumes:[Unidoc.VolumeMetadata]
        public
        let packages:[Unidoc.PackageMetadata]

        @inlinable public
        init(principal:PrincipalOutput?,
            canonical:Unidoc.AnyVertex?,
            vertices:[Unidoc.AnyVertex],
            volumes:[Unidoc.VolumeMetadata],
            packages:[Unidoc.PackageMetadata])
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
            principal: try bson[.principal]?.decode(),
            canonical: try bson[.canonical]?.decode(),
            vertices: try bson[.vertices].decode(),
            volumes: try bson[.volumes].decode(),
            packages: try bson[.packages].decode())
    }
}
