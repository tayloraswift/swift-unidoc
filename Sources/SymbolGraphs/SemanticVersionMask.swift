import JSONDecoding
import SemanticVersions

extension SemanticVersionMask:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<SemanticVersion.CodingKeys>) throws
    {
        try self.init(try json[.major].decode(),
            try json[.minor]?.decode(),
            try json[.patch]?.decode())
    }
}
