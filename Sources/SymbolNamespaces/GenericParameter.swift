import JSONDecoding

extension GenericParameter:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case name
        case depth
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(name: try json[.name].decode(), depth: try json[.depth].decode())
    }
}
