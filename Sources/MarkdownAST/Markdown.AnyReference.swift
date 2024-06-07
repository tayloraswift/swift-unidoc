import Sources
import Symbols

extension Markdown
{
    @frozen public
    enum AnyReference
    {
        /// A reference to a code object. These originate from inline code spans.
        case code(SourceString)
        /// An absolute (begins with slash) or relative URL. Never contains domain or scheme.
        case link(SourceString)
        /// A reference to a file, by its file name. These originate from block directive
        /// arguments, such as those in an `@Image`.
        case file(SourceString)
        /// A reference to a file, by its file path, which is often relative. These originate
        /// from ``InlineImage``s.
        case filePath(SourceString)
        /// A reference to a source location, which has already been resolved. These originate
        /// from the inlining of code snippets.
        case location(SourceLocation<Int32>)
        case symbolic(Symbol.USR)
        /// A fully-qualified URL.
        case external(url:ExternalURL)
    }
}
extension Markdown.AnyReference
{
    @inlinable public
    init(_ autolink:Markdown.InlineAutolink)
    {
        if  autolink.code
        {
            self = .code(autolink.text)
        }
        else if
            let url:Markdown.ExternalURL = .init(from: autolink.text)
        {
            self = .external(url: url)
        }
        else
        {
            self = .link(autolink.text)
        }
    }
}
