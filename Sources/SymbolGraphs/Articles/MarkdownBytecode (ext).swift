import BSON
import MarkdownABI

extension MarkdownBytecode:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        let view:BSON.BinaryView<[UInt8]> = .init(subtype: .generic, slice: self.bytes)
        view.encode(to: &field)
    }
}
extension MarkdownBytecode:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(bytes: [UInt8].init(bson.slice))
    }
}
