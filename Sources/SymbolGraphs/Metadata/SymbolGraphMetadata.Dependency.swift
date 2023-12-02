import BSON
import SemanticVersions
import SHA1
import Symbols

extension SymbolGraphMetadata
{
    @frozen public
    struct Dependency:Equatable, Sendable
    {
        public
        let package:Symbol.Package
        public
        let requirement:DependencyRequirement?
        public
        let revision:SHA1
        public
        let version:AnyVersion

        @inlinable public
        init(package:Symbol.Package,
            requirement:DependencyRequirement?,
            revision:SHA1,
            version:AnyVersion)
        {
            self.package = package
            self.requirement = requirement
            self.revision = revision
            self.version = version
        }
    }
}
extension SymbolGraphMetadata.Dependency
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case requirement_lower = "L"
        case requirement_upper = "U"
        case revision = "H"
        case version = "V"
    }
}
extension SymbolGraphMetadata.Dependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package

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

        bson[.revision] = self.revision
        bson[.version] = self.version
    }
}
extension SymbolGraphMetadata.Dependency:BSONDocumentDecodable
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

        self.init(package: try bson[.package].decode(),
            requirement: requirement,
            revision: try bson[.revision].decode(),
            version: try bson[.version].decode())
    }
}
