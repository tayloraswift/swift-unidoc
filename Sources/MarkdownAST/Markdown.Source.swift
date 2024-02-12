import Sources

extension Markdown
{
    /// An object representing some markdown source text.
    ///
    /// This type is completely immutable, but it is a class and not a struct because many
    /// markdown AST nodes store references to their source text, and it is more efficient to
    /// store (and copy) a pointer than a struct that wraps a long (heap-allocated) ``String``.
    ///
    /// The AST nodes themselves store references and not ``SourcePosition``s because a markdown
    /// document may incorporate AST nodes from multiple source files.
    public final
    class Source:Sendable
    {
        /// The absolute location of the markdown source within a larger source file,
        /// if known. If the markdown source was a standalone markdown file, this is
        /// ``SourceLocation/zero``.
        public
        let origin:SourceLocation<Int32>?
        /// The unparsed markdown source text.
        public
        let text:String

        @inlinable public
        init(origin:SourceLocation<Int32>?, text:String)
        {
            self.origin = origin
            self.text = text
        }
    }
}
extension Markdown.Source
{
    @inlinable public convenience
    init(file:Int32, text:String)
    {
        self.init(origin: .init(position: .zero, file: file), text: text)
    }
}
extension Markdown.Source:ExpressibleByStringLiteral
{
    @inlinable public convenience
    init(stringLiteral:String)
    {
        self.init(origin: nil, text: stringLiteral)
    }
}
