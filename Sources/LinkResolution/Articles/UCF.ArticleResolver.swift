import Symbols
import UCF

extension UCF {
    @frozen public struct ArticleResolver {
        public let table: ArticleTable
        public let scope: ArticleScope

        @inlinable public init(table: ArticleTable, scope: ArticleScope) {
            self.table = table
            self.scope = scope
        }
    }
}
extension UCF.ArticleResolver {
    public func resolve(_ doclink: Doclink, docc: Bool = false) -> Int32? {
        self.table.resolve(doclink, docc: docc, in: self.scope)
    }
}
