import JSONDecoding
import PackageGraphs

extension PackageManifest.Target
{
    @frozen public
    struct Dependencies:Equatable, Sendable
    {
        public
        var products:[Dependency<ProductIdentifier>]
        public
        var targets:[Dependency<String>]

        @inlinable public
        init(
            products:[Dependency<ProductIdentifier>] = [],
            targets:[Dependency<String>] = [])
        {
            self.products = products
            self.targets = targets
        }
    }
}
extension PackageManifest.Target.Dependencies
{
    func products(on platform:PlatformIdentifier)
        -> PackageManifest.Target.DependencyView<ProductIdentifier>
    {
        .init(platform: platform, base: self.products)
    }
    func targets(on platform:PlatformIdentifier)
        -> PackageManifest.Target.DependencyView<String>
    {
        .init(platform: platform, base: self.targets)
    }
}
extension PackageManifest.Target.Dependencies:JSONDecodable
{
    public
    init(json:JSON) throws
    {
        self.init()

        let array:JSON.Array = try .init(json: json)
        for json:JSON.ExplicitField<Int> in array
        {
            enum CodingKeys:String
            {
                case byName
                case target
                case product
            }

            try json.decode(using: CodingKeys.self)
            {
                let json:JSON.ExplicitField<CodingKeys> = try $0.single()

                enum Platforms:String
                {
                    case names = "platformNames"
                }

                switch json.key
                {
                case .target, .byName:
                    self.targets.append(try json.decode(as: JSON.Array.self)
                    {
                        try $0.shape.expect(count: 2)
                        return .init(id: try $0[0].decode(),
                            platforms: try $0[1].decode(as: JSON.ObjectDecoder<Platforms>?.self)
                            {
                                try $0?[.names].decode() ?? []
                            })
                    })

                case .product:
                    self.products.append(try json.decode(as: JSON.Array.self)
                    {
                        try $0.shape.expect(count: 4)
                        return .init(id: .init(name: try $0[0].decode(),
                                package: try $0[1].decode()),
                            platforms: try $0[3].decode(as: JSON.ObjectDecoder<Platforms>?.self)
                            {
                                try $0?[.names].decode() ?? []
                            })
                    })
                }
            }
        }
    }
}
