@frozen public
enum DeclarationFragmentElision:UInt8, Hashable, Equatable, Sendable
{
    /// The fragment will be elided in abridged signatures only.
    case abridged   = 0x10
    /// The fragment will be elided in expanded signatures only.
    /// This occurs when unclassified text is different between
    /// abridged and full declarations.
    case expanded   = 0x20
    /// The fragment will never be elided. If this type is wrapped
    /// in an optional, this value indicates that the fragment
    /// should not only be kept, but emphasized if appropriate.
    case never      = 0x40
}
