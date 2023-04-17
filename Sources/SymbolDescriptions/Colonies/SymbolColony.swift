import JSONDecoding

@frozen public
struct SymbolColony:Equatable, Sendable
{
    public
    let metadata:Metadata
    public
    let culture:ModuleIdentifier
    public
    let symbols:[SymbolDescription]
    public
    let relationships:[SymbolRelationship]

    init(metadata:Metadata,
        culture:ModuleIdentifier,
        symbols:[SymbolDescription],
        relationships:[SymbolRelationship])
    {
        self.metadata = metadata
        self.culture = culture
        self.symbols = symbols
        self.relationships = relationships
    }
}
extension SymbolColony:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case metadata

        case module
        enum Module:String
        {
            case name
        }

        case symbols
        case relationships
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            metadata: try json[.metadata].decode(),
            culture: try json[.module].decode(using: CodingKeys.Module.self)
            {
                try $0[.name].decode()
            },
            symbols: try json[.symbols].decode(),
            relationships: try json[.relationships].decode())
    }
}
