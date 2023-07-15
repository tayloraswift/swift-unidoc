import Availability
import JSONDecoding
import SemanticVersions

extension Availability.VersionRange:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<PatchVersion.CodingKey>) throws
    {
        //  This allows us to model extremely high version numbers
        if  let major:UInt16 = .init(exactly: try json[.major].decode(to: UInt.self))
        {
            self = .since(try .init(major,
                try json[.minor]?.decode(),
                try json[.patch]?.decode()))
        }
        else
        {
            self = .since(nil)
        }
    }
}
