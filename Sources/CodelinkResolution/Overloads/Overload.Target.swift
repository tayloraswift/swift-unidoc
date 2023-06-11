extension Overload
{
    @frozen public
    enum Target:Equatable, Hashable, Sendable
    {
        case scalar(Address)
        case vector(Address, self:Address)
    }
}
