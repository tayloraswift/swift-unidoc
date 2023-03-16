import JSONDecoding
import PackageMetadata

public
struct PackageManifest:Identifiable, Equatable, Sendable
{
    public
    let id:PackageIdentifier
    public
    let root:PackageRoot
    public
    let dependencies:[Dependency]
    public
    let products:[Product]

    @inlinable public
    init(id:PackageIdentifier,
        root:PackageRoot,
        dependencies:[Dependency] = [],
        products:[Product] = [])
    {
        self.id = id
        self.root = root
        self.dependencies = dependencies
        self.products = products
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
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(id: try json[.id].decode(),
            root: try json[.root].decode(as: JSON.ObjectDecoder<CodingKeys.Root>.self)
            {
                try $0[.root].decode(as: JSON.SingleElementRepresentation<PackageRoot>.self,
                    with: \.value)
            },
            dependencies: try json[.dependencies].decode(),
            products: try json[.products].decode())
    }
}
