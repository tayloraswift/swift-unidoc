extension MarkdownInstruction
{
    /// An instruction that pops a container element from the document stack.
    @frozen public
    enum Pop:Equatable, Hashable, Sendable
    {
        case pop
    }
}
extension MarkdownInstruction.Pop:MarkdownInstructionType
{
    @inlinable public static
    var marker:MarkdownBytecode.Marker { .pop }
    @inlinable public
    var rawValue:Void { return }
}
