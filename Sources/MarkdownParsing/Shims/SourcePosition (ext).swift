import Markdown
import Sources

extension SourcePosition
{
    init?(_ position:Markdown.SourceLocation)
    {
        /// swift-markdown uses 1-based indexing for line/column numbers!
        self.init(line: position.line - 1, column: position.column - 1)
    }
}
