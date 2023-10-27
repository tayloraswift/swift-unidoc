import JSONDecoding
import Signatures

extension GenericParameter:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case name
        case depth
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(name: try json[.name].decode(), depth: try json[.depth].decode())
    }
}
