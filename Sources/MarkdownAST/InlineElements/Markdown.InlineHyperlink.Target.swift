import Sources

extension Markdown.InlineHyperlink
{
    @frozen public
    enum Target:Sendable
    {
        /// The link target has already been outlined.
        case outlined   (Int)
        /// The link target is a fragment within the current document. The string includes a
        /// leading `#`.
        case fragment   (String)
        /// The link target is an absolute path. The string includes a leading `/`.
        case absolute   (Markdown.SourceString)
        /// The link target is a relative path. The string does not include a leading `./`.
        case relative   (Markdown.SourceString)
        /// The link target is an external URL. The string includes the scheme.
        case external   (Markdown.SourceString)
    }
}
