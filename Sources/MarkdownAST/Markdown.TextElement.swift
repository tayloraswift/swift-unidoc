import MarkdownABI

extension Markdown
{
    public
    protocol TextElement:TreeElement
    {
        /// Writes the plain text content of this element to the input string.
        static
        func += (text:inout String, self:Self)

        /// Returns the plain text content of this element.
        var text:String { get }

        /// Rewrites all inline hyperlink targets in this element.
        mutating
        func rewrite(by rewrite:(inout InlineHyperlink.Target?) throws -> ()) rethrows

        /// Replaces symbolic codelinks in this element’s inline content
        /// with references.
        mutating
        func outline(by register:(AnyReference) throws -> Int?) rethrows
    }
}
extension Markdown.TextElement
{
    @inlinable public
    var text:String
    {
        var text:String = ""
        text += self
        return text
    }

    /// Does nothing.
    @inlinable public mutating
    func rewrite(by _:(inout Markdown.InlineHyperlink.Target?) throws -> ()) rethrows
    {
    }

    /// Does nothing.
    @inlinable public mutating
    func outline(by _:(Markdown.AnyReference) throws -> Int?)
    {
    }
}
