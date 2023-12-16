extension Timestamp
{
    @frozen public
    enum Weekday:Int32, Equatable, Hashable, Sendable
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
