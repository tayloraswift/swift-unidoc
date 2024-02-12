extension Markdown
{
    public
    typealias ParsingEngine = _MarkdownParsingEngine
}
public
protocol _MarkdownParsingEngine
{
    func parse(_ source:borrowing MarkdownSource) -> [Markdown.BlockElement]
}
