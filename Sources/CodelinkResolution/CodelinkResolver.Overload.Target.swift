extension CodelinkResolver.Overload
{
    @frozen public
    enum Target:Equatable, Hashable
    {
        case scalar(Address)
        case vector(Address, self:Address)
    }
}
extension CodelinkResolver.Overload.Target:Sendable where Address:Sendable
{
}
