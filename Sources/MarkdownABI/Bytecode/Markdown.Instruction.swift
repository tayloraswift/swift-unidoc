extension Markdown
{
    @frozen public
    enum Instruction:Equatable, Hashable, Sendable
    {
        case invalid

        case attribute(Bytecode.Attribute, Int? = nil)
        case emit(Bytecode.Emission)
        case load(Int)
        case push(Bytecode.Context)
        case pop
        case utf8(UInt8)
    }
}
