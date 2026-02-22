import JSONDecoding
import Sources

extension SymbolGraphPart.Vertex.Doccomment {
    struct Line: Equatable, Sendable {
        let start: SourcePosition?
        let text: String

        init(_ text: String, at start: SourcePosition?) {
            self.start = start
            self.text = text
        }
    }
}
extension SymbolGraphPart.Vertex.Doccomment.Line: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case text

        case range
        enum Range: String {
            //  We cannot factor this into a conformance on SourcePosition,
            //  because we want to recover from position overflow.
            case start
            enum Start: String {
                case line
                case column = "character"
            }
        }
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            try json[.text].decode(),
            at: try json[.range]?.decode(using: CodingKey.Range.self) {
                try $0[.start].decode(using: CodingKey.Range.Start.self) {
                    .init(line: try $0[.line].decode(), column: try $0[.column].decode())
                }
            }
        )
    }
}
