import BSON
import Symbols

extension Symbol.Decl: BSONBinaryEncodable {
    /// Encodes the symbol declaration as a binary array, with the language tag in the binary
    /// subtype byte. The purpose of encoding it as binary data, and not as a UTF-8 string is
    /// to exempt it from string collation. This is important because mangled symbol identifiers
    /// are always case-sensitive.
    @inlinable public func encode(to bson: inout BSON.BinaryEncoder) {
        bson.subtype = .custom(code: 0x80 | self.language.ascii)
        bson += self.suffix.utf8
    }
}
extension Symbol.Decl: BSONBinaryDecodable {
    @inlinable public init(bson: BSON.BinaryDecoder) throws {
        let suffix: String = .init(decoding: bson.bytes, as: Unicode.ASCII.self)
        self.init(Language.init(ascii: bson.subtype.rawValue & 0x7F), ascii: suffix)
    }
}
