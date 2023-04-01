extension MarkdownInstruction
{
    @frozen public
    enum Attribute:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case alt = 0x00
        case `class`
        case checked
        case disabled
        case href
        case src
        case title
        case type

        /// Pseudo-attribute, expands to `class='language-<value>'`.
        case language = 0x80
    }
}
extension MarkdownInstruction.Attribute:MarkdownInstructionType
{
    public
    typealias RawValue = UInt8
    
    @inlinable public static
    var marker:MarkdownBytecode.Marker { .attribute }
}
