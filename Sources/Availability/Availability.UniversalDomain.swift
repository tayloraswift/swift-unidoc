extension Availability
{
    @frozen public 
    enum UniversalDomain
    {
    }
}
extension Availability.UniversalDomain:AvailabilityDomain
{
    public
    typealias Deprecation = Availability.Range<Never>
}
