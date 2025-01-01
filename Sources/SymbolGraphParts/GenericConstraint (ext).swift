import JSONDecoding
import Signatures

extension GenericConstraint:JSONObjectDecodable, JSONDecodable where Scalar:JSONDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case kind
        case lhs
        case rhs
        case rhsPrecise
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self = .where(try json[.lhs].decode(),
            is: try json[.kind].decode(as: Kind.self, with: \.operator),
            to: .init(spelling: try json[.rhs].decode(),
                nominal: try json[.rhsPrecise]?.decode()))
    }
}
