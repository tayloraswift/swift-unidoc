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
            case .sunday:       return "Sun"
            case .monday:       return "Mon"
            case .tuesday:      return "Tue"
            case .wednesday:    return "Wed"
            case .thursday:     return "Thu"
            case .friday:       return "Fri"
            case .saturday:     return "Sat"
            }
        }
    }
}
