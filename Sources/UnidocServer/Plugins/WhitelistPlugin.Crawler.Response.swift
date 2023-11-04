import IP
import JSON

extension WhitelistPlugin.Crawler
{
    struct Response
    {
        let prefixes:[IP.Block<IP.V6>]

        init(prefixes:[IP.Block<IP.V6>])
        {
            self.prefixes = prefixes
        }
    }
}
extension WhitelistPlugin.Crawler.Response:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case prefixes
        enum Prefix:String, Sendable
        {
            case ipv4Prefix
            case ipv6Prefix
        }
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let prefixes:[IP.Block<IP.V6>] = try json[.prefixes].decode(as: JSON.Array.self)
        {
            try $0.map
            {
                let object:JSON.ObjectDecoder<CodingKey.Prefix> = try $0.decode()
                let prefix:JSON.ExplicitField<CodingKey.Prefix> = try object.single()

                switch prefix.key
                {
                case .ipv4Prefix:
                    let prefix:IP.Block<IP.V4> = try prefix.decode()
                    return .init(v4: prefix)

                case .ipv6Prefix:
                    return try prefix.decode()
                }
            }
        }

        self.init(prefixes: prefixes)
    }
}
