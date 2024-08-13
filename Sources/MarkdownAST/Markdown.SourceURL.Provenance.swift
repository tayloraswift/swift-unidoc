extension Markdown.SourceURL
{
    @frozen public
    enum Provenance
    {
        /// The URL originated from an attribute and likely has associated link text.
        case attribute
        /// The URL originated from an autolink and the link text must be obtained by
        /// interpreting the URL itself.
        case autolink
    }
}
