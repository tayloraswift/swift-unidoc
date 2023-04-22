import JSONDecoding
import Repositories

extension SymbolDescription
{
    @frozen public
    struct Documentation:Equatable, Sendable
    {
        public
        let culture:ModuleIdentifier?
        public
        let comment:String

        public
        init(culture:ModuleIdentifier?, comment:String)
        {
            self.culture = culture
            self.comment = comment
        }
    }
}
extension SymbolDescription.Documentation:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case culture = "module"
        case lines

        enum Line:String
        {
            case text
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(culture: try json[.culture]?.decode(),
            comment: try json[.lines].decode(as: JSON.Array.self)
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
