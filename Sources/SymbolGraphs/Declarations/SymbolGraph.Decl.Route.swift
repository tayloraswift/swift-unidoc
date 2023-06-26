extension SymbolGraph.Decl
{
    @frozen public
    enum Route:UInt8, Equatable, Hashable, Sendable
    {
        case unhashed = 0
        case hashed = 1
    }
}
