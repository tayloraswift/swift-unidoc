import MarkdownABI

/// A type that models a markdown DOM node.
public
protocol MarkdownElement
{
    /// Replaces symbolic codelinks in this element’s inline content
    /// with references.
    mutating
    func outline(by register:(_ symbol:String) throws -> UInt32?) rethrows

    func emit(into binary:inout MarkdownBinaryEncoder)
}
extension MarkdownElement
{
    /// Does nothing.
    @inlinable public mutating
    func outline(by _:(_ symbol:String) throws -> UInt32?)
    {
    }
}
