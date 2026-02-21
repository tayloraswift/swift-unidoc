import FNV1
import BSON
import UnidocAPI

extension Unidoc {
    @frozen public struct RedirectSource: Hashable, Sendable {
        public let volume: Edition
        public let stem: Stem
        /// We don’t have any reason to correlate redirects themselves across volumes.
        /// Therefore, we store only the 24-bit hash, to simplify queries.
        public let hash: FNV24

        @inlinable public init(volume: Edition, stem: Stem, hash: FNV24) {
            self.volume = volume
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Unidoc.RedirectSource {
    @frozen public enum CodingKey: String, Sendable {
        case volume = "V"
        case stem = "U"
        case hash = "H"
    }
}
extension Unidoc.RedirectSource: BSONDocumentEncodable {
    public func encode(to document: inout BSON.DocumentEncoder<CodingKey>) {
        document[.volume] = self.volume
        document[.stem] = self.stem
        document[.hash] = self.hash
    }
}
extension Unidoc.RedirectSource: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            volume: try bson[.volume].decode(),
            stem: try bson[.stem].decode(),
            hash: try bson[.hash].decode()
        )
    }
}
