/// SymbolGraphGen emits no information about SPIs, except whether a
/// symbol has at least one. So this struct is completely empty.
@frozen public
struct SymbolSPI:Hashable, Sendable
{
    @inlinable public
    init()
    {
    }
}
