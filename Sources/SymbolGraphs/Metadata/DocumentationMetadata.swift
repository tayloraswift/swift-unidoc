import BSONDecoding
import BSONEncoding
import PackageGraphs
import SemanticVersions

public
struct DocumentationMetadata:Equatable, Sendable
{
    /// The package this symbolgraph is for.
    public
    let package:PackageIdentifier
    public
    let triple:Triple

    public
    let format:SemanticVersion

    public
    let revision:Repository.Revision?
    public
    let ref:SemanticRef?

    public
    let requirements:[PlatformRequirement]
    public
    let dependencies:[Dependency]
    public
    let products:[ProductNode]

    public
    init(package:PackageIdentifier, triple:Triple,
        format:SemanticVersion = .v(0, 1, 0),
        revision:Repository.Revision? = nil,
        ref:SemanticRef? = nil,
        requirements:[PlatformRequirement] = [],
        dependencies:[Dependency] = [],
        products:[ProductNode] = [])
    {
        self.package = package
        self.triple = triple
        self.format = format

        self.revision = revision
        self.ref = ref

        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products
    }
}
extension DocumentationMetadata
{
    public static
    func swift(triple:Triple, ref:SemanticRef? = nil) -> Self
    {
        .init(package: .swift, triple: triple, ref: ref)
    }
}
extension DocumentationMetadata
{
    @frozen public
    enum CodingKeys:String
    {
        case package
        case triple
        case format
        case revision
        case ref
        case requirements
        case dependencies
        case products
    }
}
extension DocumentationMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.package] = self.package
        bson[.triple] = self.triple
        bson[.format] = self.format
        bson[.revision] = self.revision
        bson[.ref] = self.ref
        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.products] = self.products
    }
}
extension DocumentationMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(package: try bson[.package].decode(),
            triple: try bson[.triple].decode(),
            format: try bson[.format].decode(),
            revision: try bson[.revision]?.decode(),
            ref: try bson[.ref]?.decode(),
            requirements: try bson[.requirements]?.decode() ?? [],
            dependencies: try bson[.dependencies]?.decode() ?? [],
            products: try bson[.products].decode())
    }
}
