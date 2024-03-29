import JSONDecoding
import SemanticVersions

extension NumericVersion:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<PatchVersion.CodingKey>) throws
    {
        try self.init(try json[.major].decode(),
            try json[.minor]?.decode(),
            try json[.patch]?.decode())
    }
}
