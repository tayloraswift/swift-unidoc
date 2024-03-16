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
        case requirement_suffix = "B"
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

        case .range(let version, to: let upper)?:
            bson[.requirement_upper] = upper
            fallthrough

        case .exact(let version)?:
            let suffix:String = "\(version.suffix)"
            bson[.requirement_lower] = version.number
            bson[.requirement_suffix] = suffix.isEmpty ? nil : suffix
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
        let requirement:SymbolGraphMetadata.DependencyRequirement? = .init(
            suffix: try bson[.requirement_suffix]?.decode(),
            lower: try bson[.requirement_lower]?.decode(),
            upper: try bson[.requirement_upper]?.decode())

        self.init(exonym: try bson[.exonym].decode(),
            requirement: requirement,
            resolution: try bson[.resolution]?.decode(),
            pinned: try bson[.pinned]?.decode())
    }
}
