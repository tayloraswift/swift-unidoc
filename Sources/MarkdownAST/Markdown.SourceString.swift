import Sources

extension Markdown
{
    @frozen public
    struct SourceString:Equatable, Hashable, Sendable
    {
        /// Where in the markdown source text this reference originated from.
        public
        let source:SourceReference<Markdown.Source>
        /// The text value of this reference.
        public
        let string:String

        @inlinable public
        init(source:SourceReference<Markdown.Source>, string:String)
        {
            self.source = source
            self.string = string
        }
    }
}
extension Markdown.SourceString:CustomStringConvertible
{
    @inlinable public
    var description:String { self.string }
}
