import JSONDecoding
import Signatures

extension Signature.Generics:JSONDecodable, JSONObjectDecodable where Scalar:JSONDecodable
{
    public
    enum CodingKeys:String
    {
        case parameters
        case constraints
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            constraints: try json[.constraints]?.decode() ?? [],
            parameters: try json[.parameters]?.decode() ?? [])
    }
}
