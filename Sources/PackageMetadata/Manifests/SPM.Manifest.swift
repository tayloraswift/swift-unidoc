import JSON
import PackageGraphs
import SemanticVersions
import SymbolGraphs
import Symbols

@available(*, deprecated, renamed: "SPM.Manifest")
public
typealias PackageManifest = SPM.Manifest

extension SPM
{
    /// Manifest ur destiny ✨
    @frozen public
    struct Manifest:Equatable, Sendable
    {
        /// The name of the package. This is *not* always the same as the package’s
        /// identity, but often is. Some packages use this field to store a “marketing
        /// name” for the package, such as `Swift Argument Parser`.
        public
        let name:String
        public
        let root:Symbol.FileBase
        public
        let requirements:[SymbolGraphMetadata.PlatformRequirement]
        public
        let dependencies:[Dependency]
        public
        let products:[Product]
        public
        let targets:[TargetNode]
        /// The `swift-tools-version` format of this manifest.
        public
        let format:PatchVersion

        @inlinable public
        init(name:String,
            root:Symbol.FileBase,
            requirements:[SymbolGraphMetadata.PlatformRequirement] = [],
            dependencies:[Dependency] = [],
            products:[Product] = [],
            targets:[TargetNode] = [],
            format:PatchVersion)
        {
            self.name = name
            self.root = root
            self.requirements = requirements
            self.dependencies = dependencies
            self.products = products
            self.targets = targets
            self.format = format
        }
    }
}
extension SPM.Manifest:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case dependencies
        case name
        case products

        case root = "packageKind"
        enum Root:String, Sendable
        {
            case root
        }

        case requirements = "platforms"
        /// Sadly, we cannot conform ``PlatformRequirement`` itself to JSONObjectDecodable,
        /// because its `CodingKey` witness would conflict with its BSONDocumentDecodable
        /// type witness.
        enum Requirements:String, Sendable
        {
            case id = "platformName"
            case min = "version"
        }

        case targets

        case format = "toolsVersion"
        enum Format:String, Sendable
        {
            case version = "_version"
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            name: try json[.name].decode(),
            root: try json[.root].decode(as: JSON.ObjectDecoder<CodingKey.Root>.self)
            {
                try $0[.root].decode(
                    as: JSON.SingleElementRepresentation<Symbol.FileBase>.self,
                    with: \.value)
            },
            requirements: try json[.requirements].decode(as: JSON.Array.self)
            {
                try $0.map
                {
                    try $0.decode(using: CodingKey.Requirements.self)
                    {
                        .init(id: try $0[.id].decode(),
                            min: try $0[.min].decode(
                                as: JSON.StringRepresentation<NumericVersion>.self,
                                with: \.value))
                    }
                }
            },
            dependencies: try json[.dependencies].decode(),
            products: try json[.products].decode(),
            targets: try json[.targets].decode(),
            format: try json[.format].decode(as: JSON.ObjectDecoder<CodingKey.Format>.self)
            {
                try $0[.version].decode(as: JSON.StringRepresentation<PatchVersion>.self,
                    with: \.value)
            })
    }
}
