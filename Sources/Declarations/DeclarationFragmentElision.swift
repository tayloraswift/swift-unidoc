@frozen public
enum DeclarationFragmentElision:UInt8, Hashable, Equatable, Sendable
{
    /// The fragment will be elided in abridged signatures only.
    case abridged   = 0x10
    /// The fragment will be elided in expanded signatures only.
    /// This occurs when unclassified text is different between
    /// abridged and full declarations. It will never receive
    /// accended coloring when shown in abridged form.
    case expanded   = 0x20
    /// The fragment will never be elided, and will receive
    /// accented coloring when shown in abridged form.
    case never      = 0x40
}
