import BSON

extension Unidoc {
    @frozen public struct BuildLog: Equatable, Sendable {
        public var text: TextStorage.Compressed
        public let type: BuildLogType

        @inlinable public init(text: TextStorage.Compressed, type: BuildLogType) {
            self.text = text
            self.type = type
        }
    }
}
extension Unidoc.BuildLog {
    @frozen public enum CodingKey: String, Sendable {
        case text = "Z"
        case type = "T"
    }
}
extension Unidoc.BuildLog: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.text] = self.text
        bson[.type] = self.type
    }
}
extension Unidoc.BuildLog: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(text: try bson[.text].decode(), type: try bson[.type].decode())
    }
}
