import HTML
import MarkdownABI
import MarkdownRendering

/// A thin wrapper around some ``MarkdownBytecode``, which conforms to
/// ``MarkdownExecutable``, and can be rendered to HTML.
struct MarkdownBinary:Equatable, Sendable
{
    let bytecode:MarkdownBytecode

    init(bytecode:MarkdownBytecode)
    {
        self.bytecode = bytecode
    }
}
extension MarkdownBinary:MarkdownRenderer
{
    /// Renders a placeholder `code` element describing the reference.
    public
    func load(_ reference:UInt32, into html:inout HTML)
    {
        html[.code] = "<reference = \(reference)>"
    }
}
