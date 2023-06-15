import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions

extension Documentation
{
    @frozen public
    struct Metadata:Equatable, Sendable
    {
        /// A package name.
        /// This is part of a documentation object’s identity.
        public
        let package:PackageIdentifier
        /// A swift target triple.
        /// This is part of a documentation object’s identity.
        public
        let triple:Triple
        /// A semantic ref, either a semantic version or an unstable identitifer.
        /// This is part of a documentation object’s identity, if non-nil.
        /// If this field is nil, other documentation objects will **not** be able
        /// to link against the relevant documentation.
        public
        let ref:SemanticRef?


        /// All other packages (and their pins) that the relevant package is aware of.
        /// This list is used to select other documentation objects to link against.
        public
        let dependencies:[Dependency]
        /// The swift toolchain the relevant documentation was generated with,
        /// which is used to select a version of the standard library to link
        /// against. This is nil if the documentation *is* the toolchain
        /// documentation.
        public
        let toolchain:SemanticRef?
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

        public
        init(package:PackageIdentifier,
            triple:Triple,
            ref:SemanticRef?,
            dependencies:[Dependency],
            toolchain:SemanticRef?,
            products:[ProductDetails],
            requirements:[PlatformRequirement] = [],
            revision:Repository.Revision? = nil)
        {
            self.package = package
            self.triple = triple
            self.ref = ref

            self.dependencies = dependencies
            self.toolchain = toolchain
            self.products = products

            self.requirements = requirements
            self.revision = revision
        }
    }
}
extension Documentation.Metadata
{
    public static
    func swift(triple:Triple, version:SemanticRef?, products:[ProductDetails]) -> Self
    {
        .init(package: .swift, triple: triple, ref: version,
            dependencies: [],
            toolchain: nil,
            products: products)
    }
}
extension Documentation.Metadata
{
    /// Returns the relevant documentation object’s identity string, if it has one.
    public
    var id:String?
    {
        self.ref.map { self.pin(self.package, $0) }
    }

    /// Returns all the relevant documentation object’s dependencies’ identity strings,
    /// including the one for its toolchain dependency.
    public
    func pins() -> [String]
    {
        var pins:[String] = []
        if  let ref:SemanticRef = self.toolchain
        {
            pins.reserveCapacity(self.dependencies.count + 1)
            pins.append(self.pin(.swift, ref))
        }
        for dependency:Dependency in self.dependencies
        {
            pins.append(self.pin(dependency.package, dependency.ref))
        }
        return pins
    }

    private
    func pin(_ package:PackageIdentifier, _ ref:SemanticRef) -> String
    {
        switch ref
        {
        case .version(let version):
            //  swift-syntax v5.8.0 x86_64-unknown-linux-gnu
            return "\(package) v\(version) \(self.triple)"

        case .unstable(let name):
            //  swift-syntax @5.9-dev x86_64-unknown-linux-gnu
            return "\(package) @\(name) \(self.triple)"
        }
    }
}
extension Documentation.Metadata
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
        case toolchain
        case products
    }
}
extension Documentation.Metadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.package] = self.package
        bson[.triple] = self.triple
        bson[.ref] = self.ref

        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.toolchain] = self.toolchain
        bson[.products] = self.products

        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.revision] = self.revision
    }
}
extension Documentation.Metadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(package: try bson[.package].decode(),
            triple: try bson[.triple].decode(),
            ref: try bson[.ref]?.decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            toolchain: try bson[.toolchain]?.decode(),
            products: try bson[.products].decode(),
            requirements: try bson[.requirements]?.decode() ?? [],
            revision: try bson[.revision]?.decode())
    }
}
