extension SymbolPhylum
{
    @frozen public
    enum ObjectivityFilter:Equatable, Hashable, Sendable
    {
        case `class`
        case `static`
    }
}
