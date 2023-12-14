import BSON
import MarkdownABI
import SymbolGraphs

extension Unidoc
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
extension Unidoc.Passage
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case outlines = "o"
        case markdown = "M"
    }
}
extension Unidoc.Passage:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.outlines] = self.outlines.isEmpty ? nil : self.outlines
        bson[.markdown] = self.markdown
    }
}
extension Unidoc.Passage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            markdown: try bson[.markdown].decode())
    }
}
