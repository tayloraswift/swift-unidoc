import Sources
import Symbols

extension Markdown
{
    @frozen public
    enum AnyReference
    {
        /// A symbolic (ABI) reference to a code object.
        case symbolic(usr:Symbol.USR)
        /// A lexical (API) path reference to a code object. These originate from inline code
        /// spans.
        case lexical(ucf:SourceString)
        /// A URL reference, which may be external or internal.
        case link(url:SourceURL)
        /// A reference to a file, by its file name. These originate from block directive
        /// arguments, such as those in an `@Image`.
        case file(SourceString)
        /// A reference to a file, by its file path, which is often relative. These originate
        /// from ``InlineImage``s.
        case filePath(SourceString)
        /// A reference to a source location, which has already been resolved. These originate
        /// from the inlining of code snippets.
        case location(SourceLocation<Int32>)
    }
}
extension Markdown.AnyReference
{
    @inlinable public
    static func link(url:__owned Markdown.SourceString) -> Self { .link(url: .init(from: url)) }
}
extension Markdown.AnyReference
{
    @inlinable public
    init(_ autolink:Markdown.InlineAutolink)
    {
        self = autolink.code ? .lexical(ucf: autolink.text) : .link(url: autolink.text)
    }
}
