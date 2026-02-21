import BSON
import Symbols

extension SymbolGraph {
    @frozen public struct Product: Equatable, Hashable, Sendable {
        public let name: String
        public let type: ProductType
        public var dependencies: [Symbol.Product]
        public var cultures: [Int]

        @inlinable public init(
            name: String,
            type: ProductType,
            dependencies: [Symbol.Product],
            cultures: [Int]
        ) {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.cultures = cultures
        }
    }
}
extension SymbolGraph.Product {
    @frozen public enum CodingKey: String, Sendable {
        case name = "N"
        case type = "T"
        case dependencies = "P"
        case cultures = "C"
    }
}
extension SymbolGraph.Product: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.name] = self.name
        bson[.type] = self.type
        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.cultures] = self.cultures
    }
}
extension SymbolGraph.Product: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            name: try bson[.name].decode(),
            type: try bson[.type].decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            cultures: try bson[.cultures].decode()
        )
    }
}
