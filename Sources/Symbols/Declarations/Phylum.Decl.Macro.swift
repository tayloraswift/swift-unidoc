extension Phylum.Decl
{
    @frozen public
    enum Macro:Hashable, Equatable, Sendable
    {
        case attached
        case freestanding
    }
}
