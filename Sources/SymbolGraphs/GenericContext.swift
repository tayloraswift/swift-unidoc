import JSONDecoding

extension GenericContext<SymbolIdentifier>:JSONObjectDecodable, JSONDecodable
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
        self.init(try json[.parameters]?.decode() ?? [],
            constraints: try json[.constraints]?.decode() ?? [])
    }
}
