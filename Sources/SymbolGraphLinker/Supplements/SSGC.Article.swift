import MarkdownSemantics
import SymbolGraphs

extension SSGC {
    @frozen public struct Article {
        let type: ArticleType
        let file: Int32
        var body: Markdown.SemanticDocument

        init(type: ArticleType, file: Int32, body: Markdown.SemanticDocument) {
            self.type = type
            self.file = file
            self.body = body
        }
    }
}
extension SSGC.Article {
    func id(in culture: Int) -> Int32 {
        switch self.type {
        case .standalone(let id):   id
        case .culture:              culture * .module
        }
    }
}
