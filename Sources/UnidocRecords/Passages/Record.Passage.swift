import BSONDecoding
import BSONEncoding
import MarkdownABI
import SymbolGraphs

extension Record
{
    @frozen public
    struct Passage:Equatable, Sendable
    {
        public
        let outlines:[Outline]
        public
        let markdown:MarkdownBytecode

        @inlinable public
        init(outlines:[Outline], markdown:MarkdownBytecode)
        {
            self.outlines = outlines
            self.markdown = markdown
        }
    }
}
extension Record.Passage
{
    @frozen public
    enum CodingKey:String
    {
        case outlines = "o"
        case markdown = "M"
    }

    @inlinable public static
    subscript(key:CodingKey) -> BSON.Key { .init(key) }
}
extension Record.Passage:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.outlines] = self.outlines.isEmpty ? nil : self.outlines
        bson[.markdown] = self.markdown
    }
}
extension Record.Passage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            markdown: try bson[.markdown].decode())
    }
}
