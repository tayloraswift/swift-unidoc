import BSON

extension SymbolGraph {
    @frozen public struct Namespace: Equatable, Sendable {
        /// A range of decls that share this namespace.
        public let range: ClosedRange<Int32>
        /// The index of the namespace module.
        public let index: Int

        @inlinable public init(range: ClosedRange<Int32>, index: Int) {
            self.range = range
            self.index = index
        }
    }
}
extension SymbolGraph.Namespace {
    @frozen public enum CodingKey: String, Sendable {
        case index = "I"
        case first = "F"
        case last = "L"
    }
}
extension SymbolGraph.Namespace: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.index] = self.index
        bson[.first] = self.range.first
        bson[.last] = self.range.last
    }
}
extension SymbolGraph.Namespace: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            range: try bson[.first].decode() ... bson[.last].decode(),
            index: try bson[.index].decode()
        )
    }
}
