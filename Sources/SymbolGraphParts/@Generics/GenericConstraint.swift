import Generics
import JSONDecoding

extension GenericConstraint:JSONObjectDecodable, JSONDecodable where TypeReference:JSONDecodable
{
    public
    enum CodingKeys:String
    {
        case kind
        case lhs
        case rhs
        case rhsPrecise
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let type:TypeExpression
        if  let reference:TypeReference = try json[.rhsPrecise]?.decode()
        {
            type = .nominal(reference)
        }
        else
        {
            type = .complex(try json[.rhs].decode())
        }

        self = try json[.kind].decode(to: Kind.self)(try json[.lhs].decode(), is: type)
    }
}
