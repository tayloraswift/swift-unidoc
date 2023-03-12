extension SymbolAvailability
{
    @frozen public 
    enum Unavailable:Hashable, Sendable
    {
        case unconditionally
    }
}
