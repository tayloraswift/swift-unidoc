import MarkdownABI
import Sources

extension Markdown
{
    /// A type that models a markdown DOM node.
    public
    typealias TreeElement = _MarkdownTreeElement
}
/// The name of this protocol is ``Markdown.TreeElement``.
public
protocol _MarkdownTreeElement
{
    /// Replaces symbolic codelinks in this element’s inline content
    /// with references.
    mutating
    func outline(
        by register:(Markdown.InlineAutolink) throws -> Int?) rethrows

    func emit(into binary:inout Markdown.BinaryEncoder)
}
extension Markdown.TreeElement
{
    /// Does nothing.
    @inlinable public mutating
    func outline(by _:(Markdown.InlineAutolink) throws -> Int?)
    {
    }
}
