import JSONDecoding

extension GenericConstraint<SymbolIdentifier>:JSONObjectDecodable, JSONDecodable
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
        if  let usr:UnifiedScalarResolution = try json[.rhsPrecise]?.decode()
        {
            type = .nominal(usr.id)
        }
        else
        {
            type = .complex(try json[.rhs].decode())
        }

        self = try json[.kind].decode(to: Kind.self)(try json[.lhs].decode(), is: type)
    }
}
