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
        let package:Package
        public
        let requirement:DependencyRequirement?
        public
        let revision:SHA1
        public
        let version:AnyVersion

        @inlinable public
        init(package:Package,
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
extension SymbolGraphMetadata.Dependency:Identifiable
{
    /// Returns a fully qualified identifier for this dependency, if scoped, or simply the
    /// package identifier otherwise.
    @inlinable public
    var id:Symbol.Package { self.package.id }
}
extension SymbolGraphMetadata.Dependency
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package_name = "P"
        case package_scope = "S"
        case requirement_suffix = "B"
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
        bson[.package_name] = self.package.name
        bson[.package_scope] = self.package.scope

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

        bson[.revision] = self.revision
        bson[.version] = self.version
    }
}
extension SymbolGraphMetadata.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let requirement:SymbolGraphMetadata.DependencyRequirement? = .init(
            suffix: try bson[.requirement_suffix]?.decode(),
            lower: try bson[.requirement_lower]?.decode(),
            upper: try bson[.requirement_upper]?.decode())

        self.init(package: .init(
                scope: try bson[.package_scope]?.decode(),
                name: try bson[.package_name].decode()),
            requirement: requirement,
            revision: try bson[.revision].decode(),
            version: try bson[.version].decode())
    }
}
