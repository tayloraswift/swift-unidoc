import JSONDecoding

struct SymbolGraphNamespace:Equatable, Sendable
{
    let metadata:Metadata
    let culture:ModuleIdentifier

    init(metadata:Metadata, culture:ModuleIdentifier)
    {
        self.metadata = metadata
        self.culture = culture
    }
}
extension SymbolGraphNamespace:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case metadata
        case module
        case symbols
        case relationships
    }

    private
    enum ModuleKeys:String
    {
        case name
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            metadata: try json[.metadata].decode(),
            culture: try json[.module].decode(using: ModuleKeys.self)
            {
                try $0[.name].decode()
            })
    }
}
