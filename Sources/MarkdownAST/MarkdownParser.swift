public
protocol MarkdownParser
{
    func parse(_ source:borrowing MarkdownSource) -> [MarkdownBlock]
}
