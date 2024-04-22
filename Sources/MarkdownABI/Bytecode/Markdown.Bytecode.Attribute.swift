extension Markdown.Bytecode
{
    @frozen public
    enum Attribute:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case alt = 0x00
        /// Represents a `class` attribute. The bytecode executor will **coalesce but not
        /// de-duplicate** multiple `class` attributes into a single attribute.
        case `class` = 0x01
        case checked = 0x02
        case disabled = 0x03
        case href = 0x04
        case src = 0x05
        case title = 0x06

        /// New in 0.8.4. If an encoder emits this attribute multiple times, the last value
        /// will be used.
        ///
        /// The bytecode executor can detect if certain elements (currently: `dt` and `h1`
        /// through `h6`) contain this attribute, and will **automatically** generate a nested
        /// section anchor that links to it.
        ///
        /// The bytecode executor will percent-encode the value if needed.
        case id = 0x07

        /// New in 0.8.18. The bytecode executor will **coalesce** multiple `style` attributes
        /// into a single attribute by string concatenation. When emitting this attribute,
        /// always include trailing semicolons!
        ///
        /// We opted to use this and not a large set of pseudo-attributes to avoid cluttering
        /// the codespace, and also to help prevent encoders from accidentally emitting
        /// multiple `style` attributes.
        case style = 0x08

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
        /// Pseudo-attribute, expands to
        /// `target='_blank' rel='external noopener nofollow ugc' href='value'`.
        case external
        /// Pseudo-attribute, expands to
        /// `target='_blank' rel='external' href='value'`.
        case safelink
    }
}
