extension Availability
{
    @frozen public 
    enum Unavailable:Hashable, Sendable
    {
        case unconditionally
    }
}
