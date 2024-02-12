import MarkdownABI

extension Markdown
{
    public
    typealias BlockDirectiveType = _MarkdownBlockDirectiveType
}

public
protocol _MarkdownBlockDirectiveType:Markdown.BlockElement
{
    func configure(option:String, value:String) throws
    func append(_ element:Markdown.BlockElement) throws
}

extension Markdown.BlockDirectiveType where Self:Markdown.BlockContainer<Markdown.BlockElement>
{
    public
    func append(_ element:Markdown.BlockElement) throws
    {
        self.elements.append(element)
    }
}
