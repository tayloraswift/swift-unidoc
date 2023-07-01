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
        let referents:[Referent]
        public
        let markdown:MarkdownBytecode

        @inlinable public
        init(referents:[Referent], markdown:MarkdownBytecode)
        {
            self.referents = referents
            self.markdown = markdown
        }
    }
}
extension Record.Passage
{
    public
    enum CodingKeys:String
    {
        case referents = "R"
        case markdown = "M"
    }
}
extension Record.Passage:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.referents] = self.referents
        bson[.markdown] = self.markdown
    }
}
extension Record.Passage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(referents: try bson[.referents].decode(),
            markdown: try bson[.markdown].decode())
    }
}
