import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Volume.Vertex.Meta
{
    @frozen public
    struct Dependency:Identifiable, Equatable, Sendable
    {
        public
        let id:PackageIdentifier

        public
        var requirement:Repository.Requirement?
        public
        var resolution:Unidoc.Zone?

        @inlinable public
        init(id:PackageIdentifier,
            requirement:Repository.Requirement? = nil,
            resolution:Unidoc.Zone? = nil)
        {
            self.id = id
            self.requirement = requirement
            self.resolution = resolution
        }
    }
}
extension Volume.Vertex.Meta.Dependency
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case requirement_lower = "L"
        case requirement_upper = "U"
        case resolution = "p"
    }
}
extension Volume.Vertex.Meta.Dependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        switch self.requirement
        {
        case nil:
            break

        case .exact(let version)?:
            bson[.requirement_lower] = version

        case .range(let versions)?:
            bson[.requirement_lower] = versions.lowerBound
            bson[.requirement_upper] = versions.upperBound
        }

        bson[.resolution] = self.resolution
    }
}
extension Volume.Vertex.Meta.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let requirement:Repository.Requirement?
        switch
        (
            try bson[.requirement_lower]?.decode(to: PatchVersion.self),
            try bson[.requirement_upper]?.decode(to: PatchVersion.self)
        )
        {
        case (nil, _):
            requirement = nil

        case (let lower?, nil):
            requirement = .exact(lower)

        case (let lower?, let upper?):
            requirement = upper < lower ? nil : .range(lower ..< upper)
        }

        self.init(id: try bson[.id].decode(),
            requirement: requirement,
            resolution: try bson[.resolution]?.decode())
    }
}
