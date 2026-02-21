import JSONDecoding
import Sources
import Symbols

extension SymbolGraphPart.Vertex {
    @frozen public struct Doccomment: Equatable, Sendable {
        public let culture: Symbol.Module?
        public let start: SourcePosition?
        public let text: String

        public init(culture: Symbol.Module?, text: String, at start: SourcePosition?) {
            self.culture = culture
            self.start = start
            self.text = text
        }
    }
}
extension SymbolGraphPart.Vertex.Doccomment {
    private init(culture: Symbol.Module?, lines: [Line]) {
        self.init(
            culture: culture,
            text: lines.lazy.map(\.text).joined(separator: "\n"),
            at: lines.first?.start
        )
    }
}
extension SymbolGraphPart.Vertex.Doccomment: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case culture = "module"
        case lines
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            culture: try json[.culture]?.decode(),
            lines: try json[.lines].decode()
        )
    }
}
