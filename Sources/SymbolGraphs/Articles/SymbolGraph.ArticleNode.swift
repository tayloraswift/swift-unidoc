import BSON
import MarkdownABI
import Symbols

extension SymbolGraph
{
    /// An article node models a standalone article, which includes the ``article`` content
    /// itself, a ``headline``.
    ///
    /// The name of the type was chosen for symmetry with ``DeclNode``, but the shape of the
    /// type is more similar to that of ``Decl``. Because declarations can contain ``Article``s
    /// of their own, we use the name `ArticleNode` to emphasize their first-class nature.
    @frozen public
    struct ArticleNode:Equatable, Sendable
    {
        public
        var headline:Markdown.Bytecode
        public
        var article:Article

        @inlinable public
        init(headline:Markdown.Bytecode, article:Article = .init())
        {
            self.headline = headline
            self.article = article
        }
    }
}
extension SymbolGraph.ArticleNode:SymbolGraphNode
{
    public
    typealias Plane = SymbolGraph.ArticlePlane
    public
    typealias ID = Symbol.Article

    @inlinable public
    var isCitizen:Bool { true }
}
extension SymbolGraph.ArticleNode
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case headline = "H"
        case article = "B"
    }
}
extension SymbolGraph.ArticleNode:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.headline] = self.headline
        bson[.article] = self.article
    }
}
extension SymbolGraph.ArticleNode:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            headline: try bson[.headline].decode(),
            article: try bson[.article].decode())
    }
}
