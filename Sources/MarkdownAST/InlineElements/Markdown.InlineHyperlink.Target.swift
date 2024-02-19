import Sources

extension Markdown.InlineHyperlink
{
    @frozen public
    enum Target:Sendable
    {
        case outlined   (Int)

        case safe       (Markdown.SourceString)
        case unsafe     (String)
    }
}
