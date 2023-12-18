extension SymbolGraph
{
    @frozen public
    enum LibraryType:String, Hashable, Equatable, Sendable
    {
        case automatic
        case dynamic
        case `static`
    }
}
