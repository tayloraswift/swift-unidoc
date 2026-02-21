import BSON
import SemanticVersions
import SHA1
import Symbols

extension SymbolGraphMetadata {
    @frozen public struct Dependency: Equatable, Sendable {
        public let package: Package
        public let requirement: DependencyRequirement?
        public let revision: SHA1
        public let version: AnyVersion

        @inlinable public init(
            package: Package,
            requirement: DependencyRequirement?,
            revision: SHA1,
            version: AnyVersion
        ) {
            self.package = package
            self.requirement = requirement
            self.revision = revision
            self.version = version
        }
    }
}
extension SymbolGraphMetadata.Dependency: Identifiable {
    /// Returns a fully qualified identifier for this dependency, if scoped, or simply the
    /// package identifier otherwise.
    @inlinable public var id: Symbol.Package { self.package.id }
}
extension SymbolGraphMetadata.Dependency {
    @frozen public enum CodingKey: String, Sendable {
        case package_name = "P"
        case package_scope = "S"
        case requirement_lowerNumber = "L"
        case requirement_lowerSuffix = "B"
        case requirement_upperNumber = "U"
        case requirement_upperSuffix = "C"
        case revision = "H"
        case version = "V"
    }
}
extension SymbolGraphMetadata.Dependency: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.package_name] = self.package.name
        bson[.package_scope] = self.package.scope

        switch self.requirement {
        case nil:
            break

        case .range(let version, to: let upper)?:
            let suffix: String = "\(upper.suffix)"
            bson[.requirement_upperNumber] = upper.number
            bson[.requirement_upperSuffix] = suffix.isEmpty ? nil : suffix

            fallthrough

        case .exact(let version)?:
            let suffix: String = "\(version.suffix)"
            bson[.requirement_lowerNumber] = version.number
            bson[.requirement_lowerSuffix] = suffix.isEmpty ? nil : suffix
        }

        bson[.revision] = self.revision
        bson[.version] = self.version
    }
}
extension SymbolGraphMetadata.Dependency: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        let requirement: SymbolGraphMetadata.DependencyRequirement? = .init(
            lowerNumber: try bson[.requirement_lowerNumber]?.decode(),
            lowerSuffix: try bson[.requirement_lowerSuffix]?.decode(),
            upperNumber: try bson[.requirement_upperNumber]?.decode(),
            upperSuffix: try bson[.requirement_upperSuffix]?.decode()
        )

        self.init(
            package: .init(
                scope: try bson[.package_scope]?.decode(),
                name: try bson[.package_name].decode()
            ),
            requirement: requirement,
            revision: try bson[.revision].decode(),
            version: try bson[.version].decode()
        )
    }
}
