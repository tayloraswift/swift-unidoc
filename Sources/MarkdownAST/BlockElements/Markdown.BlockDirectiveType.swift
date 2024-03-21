import MarkdownABI
import Sources

extension Markdown
{
    public
    protocol BlockDirectiveType:BlockElement
    {
        func configure(option:String, value:SourceString) throws
        func append(_ element:BlockElement) throws

        /// Associates a source location with this block. For ideal formatting, this source range
        /// should **only** cover the block directive name.
        var source:SourceReference<Source>? { get set }
    }
}
extension Markdown.BlockDirectiveType where Self:Markdown.BlockContainer<Markdown.BlockElement>
{
    public
    func append(_ element:Markdown.BlockElement) throws
    {
        self.elements.append(element)
    }
}
