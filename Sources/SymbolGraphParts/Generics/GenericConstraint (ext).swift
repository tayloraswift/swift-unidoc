import JSONDecoding
import Signatures

extension GenericConstraint:JSONObjectDecodable, JSONDecodable where Scalar:JSONDecodable
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
        if  let scalar:Scalar = try json[.rhsPrecise]?.decode()
        {
            type = .nominal(scalar)
        }
        else
        {
            type = .complex(try json[.rhs].decode())
        }

        self = try json[.kind].decode(to: Kind.self)(try json[.lhs].decode(), is: type)
    }
}
