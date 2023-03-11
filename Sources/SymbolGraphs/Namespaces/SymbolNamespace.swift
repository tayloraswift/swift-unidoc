import JSONDecoding

struct SymbolNamespace:Equatable, Sendable
{
    let metadata:Metadata
    let culture:ModuleIdentifier
    let symbols:[Symbol]

    init(metadata:Metadata, culture:ModuleIdentifier, symbols:[Symbol])
    {
        self.metadata = metadata
        self.culture = culture
        self.symbols = symbols
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
            symbols: try json[.symbols].decode())
    }
}
