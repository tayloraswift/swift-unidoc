import MarkdownAST

extension Markdown.Tree {
    func visit(_ yield: (Markdown.BlockElement) throws -> ()) rethrows {
        for block: Markdown.BlockElement in self.blocks {
            try yield(block)
        }
    }
}
