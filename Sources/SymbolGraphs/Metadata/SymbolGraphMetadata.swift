import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions

@frozen public
struct SymbolGraphMetadata:Equatable, Sendable
{
    /// A package name.
    /// This is part of a documentation object’s identity.
    public
    let package:PackageIdentifier
    /// A version to associate with the relevant symbol graph.
    ///
    /// This is part of a documentation object’s identity, if non-nil.
    /// If this field is nil, other documentation objects will **not** be able
    /// to link against the relevant documentation.
    ///
    /// Versions are an SPM/toolchain concept; to obtain the git-based version
    /// information, use ``refname`` or ``revision``.
    public
    let version:AnyVersion?
    /// A swift target triple.
    /// This is part of a documentation object’s identity.
    public
    let triple:Triple


    /// All other packages (and their pins) that the relevant package is aware of.
    /// This list is used to select other documentation objects to link against.
    public
    let dependencies:[Dependency]
    /// The swift toolchain the relevant documentation was generated with,
    /// which is used to select a version of the standard library to link
    /// against. This is nil if the documentation *is* the toolchain
    /// documentation.
    public
    let toolchain:AnyVersion?
    /// The package products contained within the relevant documentation.
    /// The products in this list contain references to packages named in
    /// ``dependencies``. This list is used to filter other documentation objects
    /// to link against.
    public
    let products:[ProductDetails]


    /// The platform requirements of the relevant package. This field is
    /// informative only.
    public
    let requirements:[PlatformRequirement]
    /// The commit hash of the relevant documentation. It is a more specific
    /// notion of version than ``ref``, but it is used for validation only.
    public
    let revision:Repository.Revision?
    /// The git ref used to check out the original package sources, if the
    /// relevant symbol graph was generated for a source-controlled SPM package.
    /// Unlike ``version``, this is an exact string; e.g. it can be `v1.2.3`
    /// whereas ``version`` may render as `1.2.3`.
    public
    let refname:String?
    /// A prefix to append to file paths when printing diagnostics.
    public
    let root:Repository.Root?

    public
    init(package:PackageIdentifier,
        version:AnyVersion?,
        triple:Triple,
        dependencies:[Dependency],
        toolchain:AnyVersion?,
        products:[ProductDetails],
        requirements:[PlatformRequirement] = [],
        revision:Repository.Revision? = nil,
        refname:String? = nil,
        root:Repository.Root? = nil)
    {
        self.package = package
        self.triple = triple
        self.version = version

        self.dependencies = dependencies
        self.toolchain = toolchain
        self.products = products

        self.requirements = requirements
        self.revision = revision
        self.refname = refname
        self.root = root
    }
}
extension SymbolGraphMetadata
{
    public static
    func swift(triple:Triple, version:AnyVersion?, products:[ProductDetails]) -> Self
    {
        .init(package: .swift, version: version, triple: triple,
            dependencies: [],
            toolchain: nil,
            products: products)
    }
}
extension SymbolGraphMetadata
{
    /// Returns the relevant documentation object’s identity string, if it has one.
    public
    var id:String?
    {
        self.version.map { self.pin(self.package, $0) }
    }

    /// Returns all the relevant documentation object’s dependencies’ identity strings,
    /// including the one for its toolchain dependency.
    public
    func pins() -> [String]
    {
        var pins:[String] = []
        if  let version:AnyVersion = self.toolchain
        {
            pins.reserveCapacity(self.dependencies.count + 1)
            pins.append(self.pin(.swift, version))
        }
        for dependency:Dependency in self.dependencies
        {
            pins.append(self.pin(dependency.package, dependency.version))
        }
        return pins
    }

    private
    func pin(_ package:PackageIdentifier, _ version:AnyVersion) -> String
    {
        switch version.canonical
        {
        case .stable(.release(let version)):
            //  swift-syntax v5.8.0 x86_64-unknown-linux-gnu
            return "\(package) v\(version) \(self.triple)"

        case .unstable(let name):
            //  swift-syntax @5.9-dev x86_64-unknown-linux-gnu
            return "\(package) @\(name) \(self.triple)"
        }
    }
}
extension SymbolGraphMetadata
{
    @frozen public
    enum CodingKey:String
    {
        case package
        case version
        case triple
        case dependencies
        case toolchain
        case products
        case requirements
        case revision
        case refname
        case root
    }
}
extension SymbolGraphMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.version] = self.version
        bson[.triple] = self.triple

        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.toolchain] = self.toolchain
        bson[.products] = self.products

        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.revision] = self.revision
        bson[.refname] = self.refname
        bson[.root] = self.root
    }
}
extension SymbolGraphMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(package: try bson[.package].decode(),
            version: try bson[.version]?.decode(),
            triple: try bson[.triple].decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            toolchain: try bson[.toolchain]?.decode(),
            products: try bson[.products].decode(),
            requirements: try bson[.requirements]?.decode() ?? [],
            revision: try bson[.revision]?.decode(),
            refname: try bson[.refname]?.decode(),
            root: try bson[.root]?.decode())
    }
}
