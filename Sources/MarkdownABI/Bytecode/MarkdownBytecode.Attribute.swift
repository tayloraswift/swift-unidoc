extension MarkdownBytecode
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

        /// Pseudo-attribute, expands to `class='language-<value>'`.
        case language = 0x80

        /// Pseudo-attribute, expands to `type='checkbox'`. Always drops values.
        case checkbox
        /// Pseudo-attribute, expands to `align='center'`. Always drops values.
        case center
        /// Pseudo-attribute, expands to `align='left'`. Always drops values.
        case left
        /// Pseudo-attribute, expands to `align='right'`. Always drops values.
        case right
    }
}
