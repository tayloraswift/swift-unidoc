import BSONDecoding
import BSONEncoding
import MarkdownABI

extension SymbolGraph
{
    @frozen public
    struct Article<ID>:Equatable, Sendable where ID:Equatable & Sendable
    {
        public
        var outlines:[Outline]
        public
        var overview:MarkdownBytecode
        public
        var details:MarkdownBytecode
        /// The number of outlines used by the overview paragraph alone.
        public
        var fold:Int

        public
        let id:ID?

        @inlinable public
        init(outlines:[Outline] = [],
            overview:MarkdownBytecode = [],
            details:MarkdownBytecode = [],
            fold:Int? = nil,
            id:ID? = nil)
        {
            self.outlines = outlines
            self.overview = overview
            self.details = details
            self.fold = fold ?? self.outlines.endIndex

            self.id = id
        }
    }
}
extension SymbolGraph.Article
{
    @inlinable public
    var value:SymbolGraph.Article<Never>
    {
        get
        {
            .init(
                outlines: self.outlines,
                overview: self.overview,
                details: self.details,
                fold: self.fold)
        }
        set(value)
        {
            self.outlines = value.outlines
            self.overview = value.overview
            self.details = value.details
            self.fold = value.fold
        }
    }
}
extension SymbolGraph.Article
{
    public
    enum CodingKey:String
    {
        case outlines = "L"
        case overview = "O"
        case details = "D"
        case fold = "F"
        case id = "I"
    }
}
extension SymbolGraph.Article:BSONDocumentEncodable, BSONEncodable
    where ID:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.outlines] = self.outlines.isEmpty ? nil : self.outlines
        bson[.overview] = self.overview.isEmpty ? nil : self.overview
        bson[.details] = self.details.isEmpty ? nil : self.details
        bson[.fold] = self.fold == self.outlines.endIndex ? nil : self.fold
        //  This is why ``id`` is optional.
        bson[.id] = self.id
    }
}
extension SymbolGraph.Article:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            details: try bson[.details]?.decode() ?? [],
            fold: try bson[.fold]?.decode(),
            id: try bson[.id]?.decode())
    }
}
