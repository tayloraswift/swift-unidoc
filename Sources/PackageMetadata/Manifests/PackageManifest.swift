import JSONDecoding
import Repositories

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
    let dependencies:[Repository.Dependency]
    public
    let products:[Product]
    public
    let targets:[Target]

    @inlinable public
    init(name:String,
        root:Repository.Root,
        requirements:[PlatformRequirement] = [],
        dependencies:[Repository.Dependency] = [],
        products:[Product] = [],
        targets:[Target] = [])
    {
        self.name = name
        self.root = root
        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products
        self.targets = targets
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
    enum CodingKeys:String
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
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            name: try json[.name].decode(),
            root: try json[.root].decode(as: JSON.ObjectDecoder<CodingKeys.Root>.self)
            {
                try $0[.root].decode(
                    as: JSON.SingleElementRepresentation<Repository.Root>.self,
                    with: \.value)
            },
            requirements: try json[.requirements].decode(),
            dependencies: try json[.dependencies].decode(),
            products: try json[.products].decode(),
            targets: try json[.targets].decode())
    }
}
