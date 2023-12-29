extension Timestamp
{
    @frozen public
    enum Weekday:Int, Equatable, Hashable, Sendable
    {
        case sunday = 0
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
}
extension Timestamp.Weekday
{
    @inlinable public
    func advanced(by stride:Int) -> Self
    {
        .init(rawValue: (self.rawValue + stride) % 7)!
    }
    /// Returns the number of days to the given weekday, modulo 7. The result is always in
    /// the range `0 ..< 7`.
    @inlinable public
    func distance(to that:Self) -> Int
    {
        let distance:Int = that.rawValue - self.rawValue
        return distance < 0 ? distance + 7 : distance
    }
}
extension Timestamp.Weekday
{
    @inlinable public
    func short(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:
            switch self
            {
            case .sunday:       "Sun"
            case .monday:       "Mon"
            case .tuesday:      "Tue"
            case .wednesday:    "Wed"
            case .thursday:     "Thu"
            case .friday:       "Fri"
            case .saturday:     "Sat"
            }
        }
    }
}
