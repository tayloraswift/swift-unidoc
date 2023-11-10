import Sources

extension MarkdownInline.Link
{
    @frozen public
    enum Target:Equatable, Hashable, Sendable
    {
        case outlined   (Int)

        case safe       (String, SourceReference<Int>)
        case unsafe     (String)
    }
}
