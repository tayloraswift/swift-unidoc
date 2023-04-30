extension Availability
{
    @frozen public 
    enum Range<Bound>
    {
        case unconditionally
        case since(Bound)
    }
}
extension Availability.Range:Sendable where Bound:Sendable
{
}
extension Availability.Range:Equatable where Bound:Equatable
{
}
extension Availability.Range:Hashable where Bound:Hashable
{
}
