@frozen public
enum MarkdownInstruction:Equatable, Hashable, Sendable
{
    case invalid

    case attribute(MarkdownBytecode.Attribute)
    case emit(MarkdownBytecode.Emission)
    case push(MarkdownBytecode.Context)
    case pop
    case reference(UInt32)
    case utf8(UInt8)
}
