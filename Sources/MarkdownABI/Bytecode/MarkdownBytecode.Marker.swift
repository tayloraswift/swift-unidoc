extension MarkdownBytecode
{
    @frozen public
    enum Marker:UInt8, Equatable, Hashable, Sendable
    {
        /// A byte followed by an attribute.
        case attribute = 0xC0
        /// A byte followed by a four-byte reference.
        case reference = 0xC1

        /// Reserved.
        case reserved = 0xF5

        /// A no-op, can be used to partition bytecode into sections.
        case fold = 0xFC
        /// A byte followed by an element code.
        case emit = 0xFD
        /// A byte followed by an element code, arbitrary content, and
        /// eventually a complementary ``pop`` byte. Conceptually this
        /// opens a new markdown context on the stack. Pushes and pops
        /// should always balance.
        case push = 0xFE
        /// Closes the current markdown context.
        case pop = 0xFF
    }
}
extension MarkdownBytecode.Marker
{
    @inlinable public
    init(_ value:UInt8)
    {
        self = .init(rawValue: value) ?? .reserved
    }
}
