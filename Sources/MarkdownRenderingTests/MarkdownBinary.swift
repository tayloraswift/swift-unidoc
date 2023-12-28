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
extension MarkdownBinary:HTML.OutputStreamableMarkdown
{
    /// Renders a placeholder `code` element describing the reference.
    public
    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
        html[.code] = "<reference = \(reference)>"
    }
}
extension MarkdownBinary:TextOutputStreamableMarkdown
{
    /// Renders a placeholder `code` element describing the reference.
    public
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
        utf8 += "<reference = \(reference)>".utf8
    }
}
