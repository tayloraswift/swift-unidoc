import JSONDecoding

struct SymbolNamespace:Equatable, Sendable
{
    let metadata:Metadata
    let culture:ModuleIdentifier
    let symbols:[SymbolDescription]
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
extension SymbolNamespace:JSONObjectDecodable
{
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
