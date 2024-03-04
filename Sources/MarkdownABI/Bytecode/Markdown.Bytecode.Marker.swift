extension Markdown.Bytecode
{
    /// Markers inhabit the unassigned codepoints of the UTF-8 encoding.
    ///
    /// https://en.wikipedia.org/wiki/UTF-8
    @frozen public
    enum Marker:UInt8, Equatable, Hashable, Sendable
    {
        /// A byte followed by an element code, arbitrary content, and
        /// eventually a complementary ``pop`` byte. Conceptually this
        /// opens a new markdown context on the stack. Pushes and pops
        /// should always balance.
        case push = 0xC0
        /// Closes the current markdown context.
        case pop = 0xC1

        /// A byte followed by a variable-length reference
        /// (``uint8``, ``uint16``, ``uint32``, or ``uint64``). The reference does not need to
        /// occur immediately after the marker.
        @available(*, unavailable)
        case call = 0xF5

        /// A byte followed by an element code.
        case emit = 0xF6

        /// A byte followed by an 8-bit reference.
        case uint8 = 0xF7
        /// A byte followed by a 16-bit little-endian reference.
        case uint16 = 0xF8
        /// A byte followed by a 32-bit little-endian reference.
        case uint32 = 0xF9
        /// A byte followed by a 64-bit little-endian reference.
        case uint64 = 0xFA

        /// A byte followed by an attribute. The value of the attribute,
        /// if any, is literal UTF-8 text.
        case attribute = 0xFB
        /// A byte followed by an attribute. The value of the attribute
        /// is an 8-bit reference.
        case attribute8 = 0xFC
        /// A byte followed by an attribute. The value of the attribute
        /// is a 16-bit little-endian reference.
        case attribute16 = 0xFD
        /// A byte followed by an attribute. The value of the attribute
        /// is a 32-bit little-endian reference.
        case attribute32 = 0xFE
        case attribute64 = 0xFF
    }
}
