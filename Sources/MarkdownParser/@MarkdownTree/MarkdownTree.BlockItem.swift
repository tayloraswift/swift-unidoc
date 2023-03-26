import Markdown
import MarkdownTree

extension MarkdownTree.BlockItem
{
    convenience
    init(from markup:ListItem)
    {
        self.init(
            checkbox: markup.checkbox.flatMap { $0 == .checked ? .checked : nil },
            elements: markup.blockChildren.map(Self.create(from:)))
    }
}
