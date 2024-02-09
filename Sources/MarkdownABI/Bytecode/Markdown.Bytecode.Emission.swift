extension Markdown.Bytecode
{
    /// An instruction that emits a void element.
    @frozen public
    enum Emission:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case br = 0x00
        case hr
        case img
        case input
        case wbr
    }
}
