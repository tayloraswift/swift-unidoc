extension Markdown
{
    @frozen public
    enum AnyReference
    {
        /// A reference to a code object. These originate from inline code spans.
        case code(SourceString)
        /// A reference to an HTML object. These originate from inline autolinks.
        case link(SourceString)
        /// A reference to a file, by its file name. These originate from block directive
        /// arguments.
        case file(SourceString)
        /// A reference to a file, by its file path, which is often relative. These originate
        /// from ``InlineImage``s.
        case filePath(SourceString)
    }
}
extension Markdown.AnyReference
{
    @inlinable public
    init(_ autolink:Markdown.InlineAutolink)
    {
        self = autolink.code ? .code(autolink.text) : .link(autolink.text)
    }
}
extension Markdown.AnyReference
{
    @inlinable public
    var text:Markdown.SourceString
    {
        switch self
        {
        case .code(let text):       text
        case .link(let text):       text
        case .file(let text):       text
        case .filePath(let text):   text
        }
    }
}
