import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc

extension Volume.Meta
{
    @frozen public
    struct Dependency:Identifiable, Equatable, Sendable
    {
        public
        let id:Symbol.Package

        public
        var requirement:SymbolGraphMetadata.DependencyRequirement?
        public
        var resolution:Unidoc.Edition?

        @inlinable public
        init(id:Symbol.Package,
            requirement:SymbolGraphMetadata.DependencyRequirement? = nil,
            resolution:Unidoc.Edition? = nil)
        {
            self.id = id
            self.requirement = requirement
            self.resolution = resolution
        }
    }
}
extension Volume.Meta.Dependency
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case requirement_lower = "L"
        case requirement_upper = "U"
        case resolution = "p"
    }
}
extension Volume.Meta.Dependency:BSONDocumentEncodable
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
extension Volume.Meta.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let requirement:SymbolGraphMetadata.DependencyRequirement?
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
