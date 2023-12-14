import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc

extension Unidoc.VolumeMetadata
{
    @frozen public
    struct Dependency:Equatable, Sendable
    {
        public
        let symbol:Symbol.Package

        public
        var requirement:SymbolGraphMetadata.DependencyRequirement?
        public
        var resolution:PatchVersion?
        public
        var pinned:Unidoc.Edition?

        @inlinable public
        init(symbol:Symbol.Package,
            requirement:SymbolGraphMetadata.DependencyRequirement?,
            resolution:PatchVersion?,
            pinned:Unidoc.Edition?)
        {
            self.symbol = symbol
            self.requirement = requirement
            self.resolution = resolution
            self.pinned = pinned
        }
    }
}
extension Unidoc.VolumeMetadata.Dependency
{
    public
    enum CodingKey:String, Sendable
    {
        case symbol = "_id"
        case requirement_lower = "L"
        case requirement_upper = "U"
        case resolution = "S"
        case pinned = "p"
    }
}
extension Unidoc.VolumeMetadata.Dependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.symbol] = self.symbol

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
        bson[.pinned] = self.pinned
    }
}
extension Unidoc.VolumeMetadata.Dependency:BSONDocumentDecodable
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

        self.init(symbol: try bson[.symbol].decode(),
            requirement: requirement,
            resolution: try bson[.resolution]?.decode(),
            pinned: try bson[.pinned]?.decode())
    }
}
