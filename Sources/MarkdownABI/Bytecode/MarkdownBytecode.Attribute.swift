extension MarkdownBytecode
{
    @frozen public
    enum Attribute:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case alt = 0x00
        case `class` = 0x01
        case checked = 0x02
        case disabled = 0x03
        case href = 0x04
        //  Yes, the raw value is out-of-order; `id` was added in version 8.4 of the ABI.
        case id = 0x07
        case src = 0x05
        case title = 0x06

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
        /// Pseudo-attribute, expands to `rel='noopener nofollow ugc' href='value'`.
        case external
    }
}
