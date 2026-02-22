import BSON
import SymbolGraphs

extension Unidoc {
    @frozen public struct BuildPayload: Sendable {
        public let metadata: SymbolGraphMetadata
        public let zlib: ArraySlice<UInt8>
        /// The uncompressed size, in bytes.
        public let size: Int64

        @inlinable public init(
            metadata: SymbolGraphMetadata,
            zlib: ArraySlice<UInt8>,
            size: Int64
        ) {
            self.metadata = metadata
            self.zlib = zlib
            self.size = size
        }
    }
}
extension Unidoc.BuildPayload {
    @frozen public enum CodingKey: String, Sendable {
        case metadata = "M"
        case zlib = "Z"
        case size = "S"
    }
}
extension Unidoc.BuildPayload: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.metadata] = self.metadata
        bson[.zlib] = BSON.BinaryView<ArraySlice<UInt8>>.init(
            subtype: .generic,
            bytes: self.zlib
        )
        bson[.size] = self.size
    }
}
extension Unidoc.BuildPayload: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            metadata: try bson[.metadata].decode(),
            zlib: try bson[.zlib].decode(
                as: BSON.BinaryView<ArraySlice<UInt8>>.self,
                with: \.bytes
            ),
            size: try bson[.size].decode()
        )
    }
}
