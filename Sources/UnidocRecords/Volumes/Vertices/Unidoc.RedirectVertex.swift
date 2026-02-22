import BSON
import FNV1
import UnidocAPI

extension Unidoc {
    @frozen public struct RedirectVertex: Identifiable {
        public let id: RedirectSource
        public let target: Scalar
        public let hashed: Bool

        @inlinable public init(id: RedirectSource, target: Scalar, hashed: Bool) {
            self.id = id
            self.target = target
            self.hashed = hashed
        }
    }
}
extension Unidoc.RedirectVertex {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case target = "T"
        case hashed = "H"
        /// The target volume, omitted in the schema if it matches the source volume. It is
        /// omitted because in that case, it can be computed from the target vertex coordinate.
        case volume = "E"
    }
}
extension Unidoc.RedirectVertex: BSONDocumentEncodable {
    public func encode(to document: inout BSON.DocumentEncoder<CodingKey>) {
        document[.id] = self.id
        document[.target] = self.target
        document[.hashed] = self.hashed ? true : nil

        document[.volume] = self.id.volume != self.target.edition
            ? self.target.edition
            : nil
    }
}
extension Unidoc.RedirectVertex: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            target: try bson[.target].decode(),
            hashed: try bson[.hashed]?.decode() ?? false
        )
    }
}
