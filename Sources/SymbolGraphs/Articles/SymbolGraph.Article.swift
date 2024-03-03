import BSON
import MarkdownABI

extension SymbolGraph
{
    /// An article is a unit of prose that can be attached to a symbol in a symbol graph.
    ///
    /// An instance of `Article` has no identity of its own. To model a standalone article,
    /// see ``ArticleNode``.
    @frozen public
    struct Article:Equatable, Sendable
    {
        public
        var outlines:[Outline]
        public
        var overview:Markdown.Bytecode
        public
        var details:Markdown.Bytecode
        /// The number of outlines used by the overview paragraph alone.
        public
        var fold:Int
        public
        var file:Int32?

        /// Footer options.
        public
        var footer:Footer?

        @inlinable public
        init(outlines:[Outline] = [],
            overview:Markdown.Bytecode = [],
            details:Markdown.Bytecode = [],
            fold:Int? = nil,
            file:Int32? = nil,
            footer:Footer? = nil)
        {
            self.outlines = outlines
            self.overview = overview
            self.details = details
            self.fold = fold ?? self.outlines.endIndex
            self.file = file
            self.footer = footer
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
        case footer = "G"
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
        bson[.footer] = self.footer
    }
}
extension SymbolGraph.Article:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            outlines: try bson[.outlines]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            details: try bson[.details]?.decode() ?? [],
            fold: try bson[.fold]?.decode(),
            file: try bson[.file]?.decode(),
            footer: try bson[.footer]?.decode())
    }
}
