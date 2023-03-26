import Markdown
import MarkdownTree

extension MarkdownTree
{
    public
    init(parsing source:String)
    {
        self.init(from: .init(parsing: source, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ]))
    }

    public
    init(from document:Document)
    {
        self.init(document.blockChildren.map(Block.create(from:)))
    }
}
extension MarkdownTree:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(parsing: stringLiteral)
    }
}
