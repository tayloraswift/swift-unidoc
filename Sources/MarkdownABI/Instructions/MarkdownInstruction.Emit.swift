extension MarkdownInstruction
{
    /// An instruction that emits a void element.
    @frozen public
    enum Emit:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case br = 0x00
        case hr
        case img
        case input
        case wbr
    }
}
extension MarkdownInstruction.Emit:MarkdownInstructionType
{
    public
    typealias RawValue = UInt8
    
    @inlinable public static
    var marker:MarkdownBytecode.Marker { .emit }
}
