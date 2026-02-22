extension Unidoc.NounTable {
    /// A tag byte used to delimit nouns within a binary-encoded noun table.
    ///
    /// We are kind of abusing these control characters here, but the point is that
    /// they will never conflict with the UTF-8 encoding of a valid ``Shoot``.
    @frozen public enum Discriminator: UInt8 {
        case culture = 0x01
        case package = 0x02
        case foreign = 0x03
        case custom = 0x04
    }
}
