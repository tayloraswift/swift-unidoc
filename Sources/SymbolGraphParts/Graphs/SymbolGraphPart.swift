import JSONDecoding
import JSONParsing
import ModuleGraphs
import Symbols

@frozen public
struct SymbolGraphPart:Equatable, Sendable
{
    public
    let metadata:Metadata
    public
    let culture:ModuleIdentifier
    public
    let colony:ModuleIdentifier?
    public
    let symbols:[SymbolDescription]
    public
    let relationships:[Symbol.AnyRelationship]

    private
    init(metadata:Metadata,
        culture:ModuleIdentifier,
        colony:ModuleIdentifier?,
        symbols:[SymbolDescription],
        relationships:[Symbol.AnyRelationship])
    {
        self.metadata = metadata
        self.culture = culture
        self.colony = colony
        self.symbols = symbols
        self.relationships = relationships
    }
}
extension SymbolGraphPart:Identifiable
{
    @inlinable public
    var id:ID
    {
        .init(culture: self.culture, colony: self.colony)
    }
}
extension SymbolGraphPart
{
    public
    init(json:JSON, id:ID) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json), id: id)
    }

    private
    init(json:JSON.Object, id:ID) throws
    {
        enum CodingKey:String
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

        let json:JSON.ObjectDecoder<CodingKey> = try .init(indexing: json)
        self.init(
            metadata: try json[.metadata].decode(),
            culture: try json[.module].decode(using: CodingKey.Module.self)
            {
                try $0[.name].decode()
            },
            colony: id.colony,
            symbols: try json[.symbols].decode(),
            relationships: try json[.relationships].decode())

        if  self.culture != id.culture
        {
            throw IdentificationError.culture(id, expected: self.culture)
        }
    }
}
