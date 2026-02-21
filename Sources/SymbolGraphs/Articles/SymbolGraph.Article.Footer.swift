import BSON

extension SymbolGraph.Article {
    @frozen public enum Footer: Int32, Equatable, Sendable {
        /// The linker will skip generating a footer for this article.
        case omit = 0
    }
}
extension SymbolGraph.Article.Footer: BSONDecodable, BSONEncodable {
}
