import MarkdownABI
import Sources

/// A type that models a markdown DOM node.
public
protocol MarkdownElement
{
    /// Replaces symbolic codelinks in this element’s inline content
    /// with references.
    mutating
    func outline(
        by register:(MarkdownInline.Autolink) throws -> Int?) rethrows

    func emit(into binary:inout MarkdownBinaryEncoder)
}
extension MarkdownElement
{
    /// Does nothing.
    @inlinable public mutating
    func outline(by _:(MarkdownInline.Autolink) throws -> Int?)
    {
    }
}
