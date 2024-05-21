import BSON
import MarkdownABI

extension Markdown.Bytecode:BSONBinaryEncodable
{
    public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.reserve(another: self.bytes.count)
        bson += self.bytes
    }
}
extension Markdown.Bytecode:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        self.init(bytes: [UInt8].init(bson.bytes))
    }
}
