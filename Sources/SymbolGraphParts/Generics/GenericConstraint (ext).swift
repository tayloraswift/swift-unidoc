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
        let type:GenericType<Scalar>
        if  let scalar:Scalar = try json[.rhsPrecise]?.decode()
        {
            type = .nominal(scalar)
        }
        else
        {
            type = .complex(try json[.rhs].decode())
        }

        self = .where(try json[.lhs].decode(),
            is: try json[.kind].decode(as: Kind.self, with: \.operator),
            to: type)
    }
}
