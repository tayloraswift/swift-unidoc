import JSONDecoding
import Repositories

extension TargetDependency:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case byName
        case target
        case product
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        enum Platforms:String
        {
            case names = "platformNames"
        }

        let json:JSON.ExplicitField<CodingKeys> = try json.single()
        switch json.key
        {
        case .target, .byName:
            self = .target(try json.decode(as: JSON.Array.self)
            {
                try $0.shape.expect(count: 2)
                return .init(id: try $0[0].decode(),
                    platforms: try $0[1].decode(as: JSON.ObjectDecoder<Platforms>?.self)
                    {
                        try $0?[.names].decode() ?? []
                    })
            })

        case .product:
            self = .product(try json.decode(as: JSON.Array.self)
            {
                try $0.shape.expect(count: 4)
                return .init(id: try $0[0].decode(),
                    package: try $0[1].decode(),
                    platforms: try $0[3].decode(as: JSON.ObjectDecoder<Platforms>?.self)
                    {
                        try $0?[.names].decode() ?? []
                    })
            })
        }
    }
}
