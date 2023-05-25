import JSONDecoding
import ModuleGraphs

@frozen public
struct SymbolGraphPart:Equatable, Sendable
{
    public
    let metadata:Metadata
    public
    let culture:ModuleIdentifier
    public
    let symbols:[SymbolDescription]
    public
    let relationships:[SymbolRelationship]

    public
    var id:String?

    init(id:String? = nil,
        metadata:Metadata,
        culture:ModuleIdentifier,
        symbols:[SymbolDescription],
        relationships:[SymbolRelationship])
    {
        self.metadata = metadata
        self.culture = culture
        self.symbols = symbols
        self.relationships = relationships

        self.id = id
    }
}
extension SymbolGraphPart
{
    public
    init(parsing string:String, id:String? = nil) throws
    {
        try self.init(json: try JSON.Object.init(parsing: string))
        self.id = id
    }
    public
    init(parsing utf8:[UInt8], id:String? = nil) throws
    {
        try self.init(json: try JSON.Object.init(parsing: utf8))
        self.id = id
    }
}
extension SymbolGraphPart:JSONObjectDecodable
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
