import JSONDecoding
import SemanticVersions

extension PatchVersion:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case major
        case minor
        case patch
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self = .v(
            try json[.major].decode(),
            try json[.minor].decode(),
            try json[.patch].decode())
    }
}
