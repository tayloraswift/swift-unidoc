@frozen public
struct Timestamp:Equatable, Hashable, Sendable
{
    public
    let weekday:Weekday
    public
    let date:Date
    public
    let time:Time

    @inlinable public
    init(weekday:Weekday, date:Date, time:Time)
    {
        self.weekday = weekday
        self.date = date
        self.time = time
    }
}
extension Timestamp
{
    @inlinable public
    var components:Components { .init(date: self.date, time: self.time) }
}
extension Timestamp
{
    /// Formats this timestamp as an HTTP GMT date.
    @inlinable public
    var http:String
    {
        """
        \(self.weekday.short(.en)), \
        \(self.date.day) \
        \(self.date.mon(.en)) \
        \(self.date.year) \
        \(self.time.hh):\(self.time.mm):\(self.time.ss) GMT
        """
    }
}
