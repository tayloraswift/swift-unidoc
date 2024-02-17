import MarkdownABI
import Sources

extension Markdown
{
    public
    typealias BlockDirectiveType = _MarkdownBlockDirectiveType
}

public
protocol _MarkdownBlockDirectiveType:Markdown.BlockElement
{
    func configure(option:String, value:String, from:SourceReference<Markdown.Source>) throws
    func append(_ element:Markdown.BlockElement) throws

    /// Associates a source location with this block. For ideal formatting, this source range
    /// should **only** cover the block directive name.
    var source:SourceReference<Markdown.Source>? { get set }
}

extension Markdown.BlockDirectiveType where Self:Markdown.BlockContainer<Markdown.BlockElement>
{
    public
    func append(_ element:Markdown.BlockElement) throws
    {
        self.elements.append(element)
    }
}
