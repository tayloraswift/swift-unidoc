import JSON
import PackageGraphs
import Symbols

extension TargetNode.Dependencies:JSONDecodable
{
    public
    init(json:JSON.Node) throws
    {
        self.init()

        let array:JSON.Array = try .init(json: json)
        for json:JSON.FieldDecoder<Int> in array
        {
            enum CodingKey:String, Sendable
            {
                case byName
                case target
                case product
            }

            try json.decode(using: CodingKey.self)
            {
                let json:JSON.FieldDecoder<CodingKey> = try $0.single()

                switch json.key
                {
                case .byName:
                    self.nominal.append(try json.decode(as: JSON.Array.self)
                    {
                        try $0.shape.expect(count: 2)
                        return .init(id: try $0[0].decode(), try $0[1].decode())
                    })

                case .target:
                    self.targets.append(try json.decode(as: JSON.Array.self)
                    {
                        try $0.shape.expect(count: 2)
                        return .init(id: try $0[0].decode(), try $0[1].decode())
                    })

                case .product:
                    self.products.append(try json.decode(as: JSON.Array.self)
                    {
                        try $0.shape.expect(count: 4)
                        let id:Symbol.Product = .init(name: try $0[0].decode(),
                            package: try $0[1].decode())
                        return .init(id: id, try $0[3].decode())
                    })
                }
            }
        }
    }
}

private
extension TargetNode.Dependency
{
    init(id:ID, _ platforms:TargetNode.DependencyPlatforms?)
    {
        self.init(id: id, platforms: platforms?.names ?? [])
    }
}
