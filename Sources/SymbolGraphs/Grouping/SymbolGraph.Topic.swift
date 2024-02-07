import BSON
import MarkdownABI

extension SymbolGraph
{
    @frozen public
    struct Topic:Equatable, Sendable
    {
        /// Outlines for the ``overview``.
        public
        var outlines:[Outline]
        public
        var overview:MarkdownBytecode
        public
        var members:[Outline]

        @inlinable public
        init(outlines:[Outline], overview:MarkdownBytecode, members:[Outline])
        {
            self.outlines = outlines
            self.overview = overview
            self.members = members
        }
    }
}
extension SymbolGraph.Topic
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case outlines = "L"
        case overview = "O"
        case members = "M"
    }
}
extension SymbolGraph.Topic:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.outlines] = self.outlines.isEmpty ? nil : self.outlines
        bson[.overview] = self.overview.isEmpty ? nil : self.overview
        bson[.members] = self.members
    }
}
extension SymbolGraph.Topic:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            members: try bson[.members].decode())
    }
}
