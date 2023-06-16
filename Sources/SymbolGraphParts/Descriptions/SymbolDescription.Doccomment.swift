import JSONDecoding
import ModuleGraphs
import Sources

extension SymbolDescription
{
    @frozen public
    struct Doccomment:Equatable, Sendable
    {
        public
        let culture:ModuleIdentifier?
        public
        let start:SourcePosition?
        public
        let text:String

        public
        init(culture:ModuleIdentifier?, text:String, at start:SourcePosition?)
        {
            self.culture = culture
            self.start = start
            self.text = text
        }
    }
}
extension SymbolDescription.Doccomment
{
    private
    init(culture:ModuleIdentifier?, lines:[Line])
    {
        self.init(culture: culture,
            text: lines.lazy.map(\.text).joined(separator: "\n"),
            at: lines.first?.start)
    }
}
extension SymbolDescription.Doccomment:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case culture = "module"
        case lines
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(culture: try json[.culture]?.decode(),
            lines: try json[.lines].decode())
    }
}
