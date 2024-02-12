import Sources

extension Markdown
{
    public
    typealias ParsingEngine = _MarkdownParsingEngine
}
public
protocol _MarkdownParsingEngine
{
    func parse(_ source:borrowing Markdown.Source,
        onError:(any Error, SourceReference<Markdown.Source>) -> ()) -> [Markdown.BlockElement]
}
extension Markdown.ParsingEngine
{
    /// Parses some markdown, ignoring all errors.
    @inlinable public
    func parse(_ source:borrowing Markdown.Source) -> [Markdown.BlockElement]
    {
        self.parse(source) { _, _ in }
    }
}
