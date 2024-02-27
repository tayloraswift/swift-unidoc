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
        /// The name this volume of documentation uses to refer to the package.
        public
        let exonym:Symbol.Package

        public
        var requirement:SymbolGraphMetadata.DependencyRequirement?
        public
        var resolution:PatchVersion?
        public
        var pinned:Unidoc.Edition?

        @inlinable public
        init(exonym:Symbol.Package,
            requirement:SymbolGraphMetadata.DependencyRequirement?,
            resolution:PatchVersion?,
            pinned:Unidoc.Edition?)
        {
            self.exonym = exonym
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
        case exonym = "_id"
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
        bson[.exonym] = self.exonym

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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
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

        self.init(exonym: try bson[.exonym].decode(),
            requirement: requirement,
            resolution: try bson[.resolution]?.decode(),
            pinned: try bson[.pinned]?.decode())
    }
}
