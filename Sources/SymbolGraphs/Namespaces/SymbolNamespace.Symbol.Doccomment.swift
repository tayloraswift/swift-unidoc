import JSONDecoding

extension SymbolNamespace.Symbol
{
    struct Doccomment:Equatable, Sendable
    {
        let culture:ModuleIdentifier?
        let text:String

        init(culture:ModuleIdentifier?, text:String)
        {
            self.culture = culture
            self.text = text
        }
    }
}
extension SymbolNamespace.Symbol.Doccomment:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case culture = "module"
        case lines

        enum Line:String
        {
            case text
        }
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(culture: try json[.culture]?.decode(),
            text: try json[.lines].decode(as: JSON.Array.self)
            {
                try $0.lazy.map
                {
                    try $0.decode(using: CodingKeys.Line.self)
                    {
                        try $0[.text].decode(to: String.self)
                    }
                }.joined(separator: "\n")
            })
    }
}
