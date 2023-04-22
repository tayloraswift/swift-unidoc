import JSONDecoding

public
struct PackageManifest:Identifiable, Equatable, Sendable
{
    public
    let id:PackageIdentifier
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
    init(id:PackageIdentifier,
        root:Repository.Root,
        requirements:[PlatformRequirement] = [],
        dependencies:[Repository.Dependency] = [],
        products:[Product] = [],
        targets:[Target] = [])
    {
        self.id = id
        self.root = root
        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products
        self.targets = targets
    }
}
extension PackageManifest:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case dependencies
        case id = "name"
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
        self.init(id: try json[.id].decode(),
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
