@frozen public
enum MarkdownInstruction:Equatable, Hashable, Sendable
{
    case invalid

    case attribute(MarkdownBytecode.Attribute, UInt32? = nil)
    case emit(MarkdownBytecode.Emission)
    case load(UInt32)
    case push(MarkdownBytecode.Context)
    case pop
    case utf8(UInt8)
}
