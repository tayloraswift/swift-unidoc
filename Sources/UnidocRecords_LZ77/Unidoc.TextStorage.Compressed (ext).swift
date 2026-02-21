import LZ77
import UnidocRecords

extension Unidoc.TextStorage.Compressed {
    @inlinable public static func gzip(bytes: ArraySlice<UInt8>, level: Int = 7) -> Self {
        .init(bytes: Gzip.archive(bytes: bytes, level: level, hint: 128 << 10)[...])
    }

    @inlinable public consuming func utf8() throws -> [UInt8] {
        try Gzip.extract(from: self.bytes)
    }
}
