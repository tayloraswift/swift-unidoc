import IP
import JSON

extension Swiftinit.PolicyClient
{
    struct Response
    {
        var v4:[IP.Block<IP.V4>]
        var v6:[IP.Block<IP.V6>]

        init(v4:[IP.Block<IP.V4>] = [], v6:[IP.Block<IP.V6>] = [])
        {
            self.v4 = v4
            self.v6 = v6
        }
    }
}
extension Swiftinit.PolicyClient.Response:JSONObjectDecodable
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
        self.init()

        try json[.prefixes].decode(as: JSON.Array.self)
        {
            for object:JSON.FieldDecoder<Int> in $0
            {
                let object:JSON.ObjectDecoder<CodingKey.Prefix> = try object.decode()
                let prefix:JSON.FieldDecoder<CodingKey.Prefix> = try object.single()

                switch prefix.key
                {
                case .ipv4Prefix:
                    self.v4.append(try prefix.decode())

                case .ipv6Prefix:
                    self.v6.append(try prefix.decode())
                }
            }
        }
    }
}
