import JSONDecoding
import ModuleGraphs
import PackageGraphs
import SemanticVersions

public
struct PackageManifest:Equatable, Sendable
{
    /// The name of the package. This is *not* always the same as the package’s
    /// identity, but often is.
    public
    let name:String
    public
    let root:Repository.Root
    public
    let requirements:[PlatformRequirement]
    public
    let dependencies:[PackageNode.Dependency]
    public
    let products:[Product]
    public
    let targets:[TargetNode]
    /// The `swift-tools-version` format of this manifest.
    public
    let format:PatchVersion

    @inlinable public
    init(name:String,
        root:Repository.Root,
        requirements:[PlatformRequirement] = [],
        dependencies:[PackageNode.Dependency] = [],
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
extension PackageManifest
{
    public
    init(parsing json:String) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json))
    }
}
extension PackageManifest:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case dependencies
        case name
        case products

        case root = "packageKind"
        enum Root:String
        {
            case root
        }

        case requirements = "platforms"
        case targets

        case format = "toolsVersion"
        enum Format:String
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
                    as: JSON.SingleElementRepresentation<Repository.Root>.self,
                    with: \.value)
            },
            requirements: try json[.requirements].decode(),
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
