@frozen public
enum MarkdownInstruction:Equatable, Hashable, Sendable
{
    case invalid

    case attribute(Attribute)
    case emit(Emit)
    case push(Push)
    case pop
    case reference(Reference)
    case utf8(UInt8)
}
