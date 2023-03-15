import JSONDecoding

extension PackageManifest
{
    @frozen public
    struct Root:Hashable, Equatable, Sendable
    {
        /// The absolute path to the package root, without the `file://` prefix.
        public
        let path:String

        @inlinable public
        init(_ path:String)
        {
            self.path = path
        }
    }
}
extension PackageManifest.Root:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension PackageManifest.Root:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case root
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.root].decode(as: JSON.Array.self)
        {
            try $0.shape.expect(count: 1)
            return try $0[0].decode()
        })
    }
}


public
struct PackageManifest:Identifiable, Equatable, Sendable
{
    public
    let id:PackageIdentifier
    public
    let root:Root
    public
    let products:[Product]

    @inlinable public
    init(id:PackageIdentifier, root:Root, products:[Product])
    {
        self.id = id
        self.root = root
        self.products = products
    }
}
extension PackageManifest:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
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
            root: try json[.root].decode(),
            products: try json[.products].decode())
    }
}
