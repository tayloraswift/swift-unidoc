import BSON
import SemanticVersions
import Symbols
import SHA1

@frozen public
struct SymbolGraphMetadata:Equatable, Sendable
{
    public
    var abi:PatchVersion

    /// A package identifier to associate with this symbol graph.
    public
    var package:Symbol.Package
    /// A git commit to associate with the relevant symbol graph.
    ///
    /// This is nil for local package symbol graphs.
    public
    var commit:Commit?
    /// The swift target triple of the documentation artifacts this symbol graph was compiled
    /// from.
    public
    var triple:Triple
    /// The swift toolchain the relevant documentation was generated with, which is used to
    /// select a version of the standard library to link against.
    ///
    /// This became mandatory for standard library symbol graphs in version 8 of the metadata
    /// format.
    public
    var swift:AnyVersion

    /// The platform requirements of the relevant package. This field is
    /// informative only.
    public
    var requirements:[PlatformRequirement]
    /// All other packages (and their pins) that the relevant package is aware of.
    /// This list is used to select other documentation objects to link against.
    public
    var dependencies:[Dependency]
    /// The package products contained within the relevant documentation.
    ///
    /// The products in this list contain references to packages named in ``dependencies``.
    /// This list is used to filter other documentation objects to link against.
    public
    var products:[Product]
    /// An optional string containing the marketing name for the package.
    public
    var display:String?
    /// An optional prefix to append to file paths when printing diagnostics.
    public
    var root:Symbol.FileBase?

    @inlinable public
    init(package:Symbol.Package,
        commit:Commit?,
        triple:Triple,
        swift:AnyVersion,
        requirements:[PlatformRequirement] = [],
        dependencies:[Dependency] = [],
        products:[Product] = [],
        display:String? = nil,
        root:Symbol.FileBase? = nil)
    {
        self.abi = SymbolGraphABI.version

        self.package = package
        self.commit = commit
        self.triple = triple
        self.swift = swift

        self.dependencies = dependencies
        self.requirements = requirements
        self.products = products
        self.display = display
        self.root = root
    }
}
extension SymbolGraphMetadata
{
    public static
    func swift(_ swift:AnyVersion,
        tagname:String,
        triple:Triple,
        products:[Product]) -> Self
    {
        let display:String
        switch swift.canonical
        {
        case .stable(.release(let version, _)):
            display = "Swift \(version.minor)"

        case .stable(let version):
            display = "Swift \(version)"

        case .unstable:
            display = "Swift Nightly"
        }

        return .init(
            package: .swift,
            commit: .init(nil, refname: tagname),
            triple: triple,
            swift: swift,
            products: products,
            display: display)
    }
}
extension SymbolGraphMetadata
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case abi
        case package
        case commit_hash = "revision"
        case commit_refname = "refname"
        case triple
        case swift = "toolchain"
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
extension SymbolGraphMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.abi] = self.abi
        bson[.package] = self.package
        bson[.commit_hash] = self.commit?.hash
        bson[.commit_refname] = self.commit?.refname
        bson[.triple] = self.triple
        bson[.swift] = self.swift

        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.products] = self.products
        bson[.display] = self.display
        bson[.root] = self.root
    }
}
extension SymbolGraphMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            commit: try bson[.commit_refname]?.decode(as: String.self)
            {
                .init(try bson[.commit_hash]?.decode(), refname: $0)
            },
            triple: try bson[.triple].decode(),
            swift: try bson[.swift].decode(),
            requirements: try bson[.requirements]?.decode() ?? [],
            dependencies: try bson[.dependencies]?.decode() ?? [],
            products: try bson[.products].decode(),
            display: try bson[.display]?.decode(),
            root: try bson[.root]?.decode())

        self.abi = try bson[.abi].decode()
    }
}
