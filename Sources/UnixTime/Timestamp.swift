@frozen public
struct Timestamp:Equatable, Hashable, Sendable
{
    public
    let components:Components
    public
    let weekday:Weekday

    @inlinable public
    init(components:Components, weekday:Weekday)
    {
        self.components = components
        self.weekday = weekday
    }
}
extension Timestamp
{
    /// Formats this timestamp as an HTTP GMT date.
    @inlinable public
    var http:String
    {
        """
        \(self.weekday.short(.en)), \
        \(self.components.day) \
        \(self.components.mon(.en)) \
        \(self.components.year) \
        \(self.components.hh):\(self.components.mm):\(self.components.ss) GMT
        """
    }
}
