import JSONDecoding
import Sources

extension SymbolDescription.Doccomment
{
    struct Line:Equatable, Sendable
    {
        let start:SourcePosition?
        let text:String

        init(_ text:String, at start:SourcePosition?)
        {
            self.start = start
            self.text = text
        }
    }
}
extension SymbolDescription.Doccomment.Line:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case text

        case range
        enum Range:String
        {
            //  We cannot factor this into a conformance on SourcePosition,
            //  because we want to recover from position overflow.
            case start
            enum Start:String
            {
                case line
                case column = "character"
            }
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.text].decode(),
            at: try json[.range]?.decode(using: CodingKeys.Range.self)
            {
                try $0[.start].decode(using: CodingKeys.Range.Start.self)
                {
                    .init(line: try $0[.line].decode(), column: try $0[.column].decode())
                }
            })
    }
}
