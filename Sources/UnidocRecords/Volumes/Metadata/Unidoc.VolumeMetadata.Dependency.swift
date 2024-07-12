import BSON
import SemanticVersions
import SymbolGraphs
import Symbols

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
        var pin:DependencyPin?

        @inlinable public
        init(exonym:Symbol.Package,
            requirement:SymbolGraphMetadata.DependencyRequirement?,
            resolution:PatchVersion?,
            pin:DependencyPin?)
        {
            self.exonym = exonym
            self.requirement = requirement
            self.resolution = resolution
            self.pin = pin
        }
    }
}
extension Unidoc.VolumeMetadata.Dependency
{
    public
    enum CodingKey:String, Sendable
    {
        case exonym = "_id"
        case requirement_lowerNumber = "L"
        case requirement_lowerSuffix = "B"
        case requirement_upperNumber = "U"
        case requirement_upperSuffix = "C"
        case resolution = "S"
        case linked = "p"
        case pinned = "q"
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
            let suffix:String = "\(upper.suffix)"
            bson[.requirement_upperNumber] = upper.number
            bson[.requirement_upperSuffix] = suffix.isEmpty ? nil : suffix
            fallthrough

        case .exact(let version)?:
            let suffix:String = "\(version.suffix)"
            bson[.requirement_lowerNumber] = version.number
            bson[.requirement_lowerSuffix] = suffix.isEmpty ? nil : suffix
        }

        bson[.resolution] = self.resolution

        switch self.pin
        {
        case .linked(let edition)?: bson[.linked] = edition
        case .pinned(let edition)?: bson[.pinned] = edition
        case nil:                   break
        }
    }
}
extension Unidoc.VolumeMetadata.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let requirement:SymbolGraphMetadata.DependencyRequirement? = .init(
            lowerNumber: try bson[.requirement_lowerNumber]?.decode(),
            lowerSuffix: try bson[.requirement_lowerSuffix]?.decode(),
            upperNumber: try bson[.requirement_upperNumber]?.decode(),
            upperSuffix: try bson[.requirement_upperSuffix]?.decode())

        let pin:Unidoc.VolumeMetadata.DependencyPin?

        if  let linked:Unidoc.Edition = try bson[.linked]?.decode()
        {
            pin = .linked(linked)
        }
        else if
            let pinned:Unidoc.Edition = try bson[.pinned]?.decode()
        {
            pin = .pinned(pinned)
        }
        else
        {
            pin = nil
        }

        self.init(exonym: try bson[.exonym].decode(),
            requirement: requirement,
            resolution: try bson[.resolution]?.decode(),
            pin: pin)
    }
}
