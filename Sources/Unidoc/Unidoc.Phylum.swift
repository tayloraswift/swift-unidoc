extension Unidoc
{
    @frozen public
    enum Phylum:Hashable, Equatable, Sendable
    {
        case decl(Decl)
        case block
        case macro
    }
}
