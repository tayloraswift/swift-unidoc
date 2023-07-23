@frozen public
enum MarkdownInstruction:Equatable, Hashable, Sendable
{
    case invalid

    case attribute(MarkdownBytecode.Attribute, Int? = nil)
    case emit(MarkdownBytecode.Emission)
    case load(Int)
    case push(MarkdownBytecode.Context)
    case pop
    case utf8(UInt8)
}
