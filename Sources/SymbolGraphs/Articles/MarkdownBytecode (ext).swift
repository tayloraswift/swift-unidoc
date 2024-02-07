import BSON
import MarkdownABI

extension MarkdownBytecode:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        let view:BSON.BinaryView<[UInt8]> = .init(subtype: .generic, bytes: self.bytes)
        view.encode(to: &field)
    }
}
extension MarkdownBytecode:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
    {
        self.init(bytes: [UInt8].init(bson.bytes))
    }
}
