import BSON
import Unidoc

extension Unidoc {
    @frozen public struct TypeTree: Identifiable, Equatable, Sendable {
        public let id: Unidoc.Scalar
        public var rows: [Noun]

        @inlinable public init(id: Unidoc.Scalar, rows: [Noun] = []) {
            self.id = id
            self.rows = rows
        }
    }
}
extension Unidoc.TypeTree {
    public enum CodingKey: String, Sendable {
        case id = "_id"
        case table = "T"
    }
}
extension Unidoc.TypeTree: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.table] = Unidoc.NounTable.init(eliding: self.rows)
    }
}
extension Unidoc.TypeTree: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            rows: try bson[.table]?.decode(as: Unidoc.NounTable.self, with: \.rows) ?? []
        )
    }
}
