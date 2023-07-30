import BSONDecoding
import BSONEncoding
import MarkdownABI
import Symbols
import Unidoc

extension SymbolGraph
{
    @frozen public
    struct ArticleNode:Equatable, Sendable
    {
        public
        var headline:MarkdownBytecode
        public
        var body:Article

        @inlinable public
        init(headline:MarkdownBytecode, body:Article = .init())
        {
            self.headline = headline
            self.body = body
        }
    }
}
extension SymbolGraph.ArticleNode:SymbolGraphNode
{
    public
    typealias Plane = UnidocPlane.Article
    public
    typealias ID = Symbol.Article

    @inlinable public
    var isCitizen:Bool { true }
}
extension SymbolGraph.ArticleNode
{
    @frozen public
    enum CodingKey:String
    {
        case headline = "H"
        case body = "B"
    }
}
extension SymbolGraph.ArticleNode:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.headline] = self.headline
        bson[.body] = self.body
    }
}
extension SymbolGraph.ArticleNode:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            headline: try bson[.headline].decode(),
            body: try bson[.body].decode())
    }
}
