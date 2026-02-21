import BSON
import SemanticVersions
import SHA1
import Symbols

@frozen public struct SymbolGraphMetadata: Equatable, Sendable {
    public var abi: PatchVersion

    /// A package identifier to associate with this symbol graph.
    public var package: Package
    /// A git commit to associate with the relevant symbol graph.
    ///
    /// This is nil for local package symbol graphs.
    public var commit: Commit?
    /// The swift target triple of the documentation artifacts this symbol graph was compiled
    /// from.
    public var triple: Symbol.Triple

    /// The swift toolchain the relevant documentation was generated with, which is used to
    /// select a version of the standard library to link against.
    ///
    /// This became mandatory for standard library symbol graphs in version 8 of the metadata
    /// format.
    public var swift: SwiftVersion
    /// The swift tools version declared in the package manifest, if the relevant documentation
    /// was generated from a package. New in 0.8.14.
    public var tools: PatchVersion?
    /// Any additional manifests that were found in the package root directory. New in 0.8.14.
    public var manifests: [MinorVersion]

    /// The platform requirements of the relevant package. This field is
    /// informative only.
    public var requirements: [PlatformRequirement]
    /// All other packages (and their pins) that the relevant package is aware of.
    /// This list is used to select other documentation objects to link against.
    public var dependencies: [Dependency]
    /// The package products contained within the relevant documentation.
    ///
    /// The products in this list contain references to packages named in ``dependencies``.
    /// This list is used to filter other documentation objects to link against.
    public var products: SymbolGraph.Table<SymbolGraph.ProductPlane, SymbolGraph.Product>
    /// An optional string containing the marketing name for the package.
    public var display: String?
    /// An optional prefix to append to file paths when printing diagnostics.
    public var root: Symbol.FileBase?

    @inlinable public init(
        package: Package,
        commit: Commit?,
        triple: Symbol.Triple,
        swift: SwiftVersion,
        tools: PatchVersion? = nil,
        manifests: [MinorVersion] = [],
        requirements: [PlatformRequirement] = [],
        dependencies: [Dependency] = [],
        products: SymbolGraph.Table<SymbolGraph.ProductPlane, SymbolGraph.Product> = [],
        display: String? = nil,
        root: Symbol.FileBase? = nil
    ) {
        self.abi = SymbolGraphABI.version

        self.package = package
        self.commit = commit
        self.triple = triple
        self.swift = swift
        self.tools = tools
        self.manifests = manifests

        self.dependencies = dependencies
        self.requirements = requirements
        self.products = products
        self.display = display
        self.root = root
    }
}
extension SymbolGraphMetadata {
    public static func swift(
        _ swift: SwiftVersion,
        commit: Commit?,
        triple: Symbol.Triple,
        products: SymbolGraph.Table<SymbolGraph.ProductPlane, SymbolGraph.Product>
    ) -> Self {
        let display: String
        switch swift.nightly {
        case nil:
            display = "Swift \(swift.version.minor)"

        case .DEVELOPMENT_SNAPSHOT:
            display = "Swift \(swift.version.minor) Nightly"
        }

        return .init(
            package: .init(name: .swift),
            commit: commit,
            triple: triple,
            swift: swift,
            products: products,
            display: display
        )
    }
}
extension SymbolGraphMetadata {
    @frozen public enum CodingKey: String, Sendable {
        case abi
        case package_name = "package"
        case package_scope = "scope"
        case commit_hash = "revision"
        case commit_refname = "refname"
        case commit_date
        case triple
        case swift_version = "toolchain"
        case swift_nightly = "toolchain_type"
        case tools
        case manifests
        case requirements
        case dependencies
        case products
        case display
        case root

        @available(*, unavailable, message: """
            This is no longer part of the metadata format (removed 8.0)
            """)
        case version

        @available(*, unavailable, message: """
            This is no longer part of the metadata format (removed 8.0)
            """)
        case github
    }
}
extension SymbolGraphMetadata: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.abi] = self.abi
        bson[.package_name] = self.package.name
        bson[.package_scope] = self.package.scope
        bson[.commit_hash] = self.commit?.sha1
        bson[.commit_refname] = self.commit?.name
        bson[.commit_date] = self.commit?.date
        bson[.triple] = self.triple
        bson[.swift_version] = self.swift.version
        bson[.swift_nightly] = self.swift.nightly
        bson[.tools] = self.tools
        bson[.manifests] = self.manifests.isEmpty ? nil : self.manifests

        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.products] = self.products
        bson[.display] = self.display
        bson[.root] = self.root
    }
}
extension SymbolGraphMetadata: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            package: .init(
                scope: try bson[.package_scope]?.decode(),
                name: try bson[.package_name].decode()
            ),
            commit: try bson[.commit_refname]?.decode(as: String.self) {
                .init(
                    name: $0,
                    sha1: try bson[.commit_hash]?.decode(),
                    date: try bson[.commit_date]?.decode()
                )
            },
            triple: try bson[.triple].decode(),
            swift: .init(
                version: try bson[.swift_version].decode(),
                nightly: try bson[.swift_nightly]?.decode()
            ),
            tools: try bson[.tools]?.decode(),
            manifests: try bson[.manifests]?.decode() ?? [],
            requirements: try bson[.requirements]?.decode() ?? [],
            dependencies: try bson[.dependencies]?.decode() ?? [],
            products: try bson[.products].decode(),
            display: try bson[.display]?.decode(),
            root: try bson[.root]?.decode()
        )

        self.abi = try bson[.abi].decode()
    }
}
