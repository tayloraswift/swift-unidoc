import JSONDecoding
import Signatures

extension Signature.Generics:JSONDecodable, JSONObjectDecodable where Scalar:JSONDecodable
{
    public
    enum CodingKey:String
    {
        case parameters
        case constraints
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            constraints: try json[.constraints]?.decode() ?? [],
            parameters: try json[.parameters]?.decode() ?? [])
    }
}
