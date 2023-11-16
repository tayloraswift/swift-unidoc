import BSONDecoding
import BSONEncoding
import MarkdownABI

extension SymbolGraph
{
    /// An article is a unit of prose that can be attached to a symbol in a symbol graph.
    ///
    /// An instance of `Article` has no identity of its own. To model a standalone article,
    /// see ``ArticleNode``.
    ///
    /// Instances of `Article` do not contain ``Topic``s, although articles are frequently
    /// stored alongside lists of topics. Articles associated with ``Extension``s are an
    /// exception; extensions can have articles, but they cannot have topics.
    @frozen public
    struct Article:Equatable, Sendable
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
        var file:Int32?

        @inlinable public
        init(outlines:[Outline] = [],
            overview:MarkdownBytecode = [],
            details:MarkdownBytecode = [],
            fold:Int? = nil,
            file:Int32? = nil)
        {
            self.outlines = outlines
            self.overview = overview
            self.details = details
            self.fold = fold ?? self.outlines.endIndex
            self.file = file
        }
    }
}
extension SymbolGraph.Article
{
    public
    enum CodingKey:String, Sendable
    {
        case outlines = "L"
        case overview = "O"
        case details = "D"
        case fold = "Z"
        case file = "F"
    }
}
extension SymbolGraph.Article:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.outlines] = self.outlines.isEmpty ? nil : self.outlines
        bson[.overview] = self.overview.isEmpty ? nil : self.overview
        bson[.details] = self.details.isEmpty ? nil : self.details
        bson[.fold] = self.fold == self.outlines.endIndex ? nil : self.fold
        bson[.file] = self.file
    }
}
extension SymbolGraph.Article:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            details: try bson[.details]?.decode() ?? [],
            fold: try bson[.fold]?.decode(),
            file: try bson[.file]?.decode())
    }
}
