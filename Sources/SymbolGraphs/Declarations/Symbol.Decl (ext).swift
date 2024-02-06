import BSON
import Symbols

extension Symbol.Decl:BSONEncodable
{
    /// Encodes the symbol declaration as a binary array, with the language tag in the binary
    /// subtype byte. The purpose of encoding it as binary data, and not as a UTF-8 string is
    /// to exempt it from string collation. This is important because mangled symbol identifiers
    /// are always case-sensitive.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        var suffix:Substring = self.suffix
            suffix.withUTF8
        {
            let language:BSON.BinarySubtype = .custom(code: 0x80 | self.language.ascii)
            let binary:BSON.BinaryView<UnsafeBufferPointer<UInt8>> = .init(
                subtype: language,
                bytes: $0)

            binary.encode(to: &field)
        }
    }
}
extension Symbol.Decl:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
    {
        let suffix:String = .init(decoding: bson.bytes, as: Unicode.ASCII.self)
        self.init(Language.init(ascii: bson.subtype.rawValue & 0x7F), ascii: suffix)
    }
}
