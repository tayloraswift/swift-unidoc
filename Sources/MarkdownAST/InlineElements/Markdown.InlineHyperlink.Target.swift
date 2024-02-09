import Sources

extension Markdown.InlineHyperlink
{
    @frozen public
    enum Target:Sendable
    {
        case outlined   (Int)

        case safe       (String, SourceReference<MarkdownSource>)
        case unsafe     (String)
    }
}
