extension Timestamp
{
    @frozen public
    struct Date:Equatable, Hashable, Sendable
    {
        public
        var year:Year
        /// The month of the year, in the range `1 ... 12`.
        public
        var month:Month
        /// The day of the month, in the range `1 ... 31`.
        public
        var day:Int32

        @inlinable public
        init(year:Year, month:Month = .january, day:Int32 = 1)
        {
            self.year = year
            self.month = month
            self.day = day
        }
    }
}
extension Timestamp.Date
{
    /// A shorthand for `self.adjacent.before`. If you need both dates, it is more efficient to
    /// call `self.adjacent` and destructure the result.
    @inlinable public
    var predecessor:Self { self.adjacent.before }

    /// A shorthand for `self.adjacent.after`. If you need both dates, it is more efficient to
    /// call `self.adjacent` and destructure the result.
    @inlinable public
    var successor:Self { self.adjacent.after }

    /// Computes the dates adjacent to this one. Performs no system calls.
    @inlinable public
    var adjacent:(before:Self, after:Self)
    {
        let (_, leap):(Timestamp.Weekday, Bool) = self.year.vibe
        let days:ClosedRange<Int32> = self.month.days(leap: leap)

        let before:Self
        let after:Self

        switch self.day
        {
        case days.lowerBound:
            if  case .january = self.month
            {
                //  December always has 31 days regardless of whether it’s a leap year.
                before = .init(year: self.year.predecessor, month: .december, day: 31)
            }
            else
            {
                let month:Timestamp.Month = self.month.predecessor
                let days:ClosedRange<Int32> = month.days(leap: leap)

                before = .init(year: self.year, month: month, day: days.upperBound)
            }

            /// All the months have at least 28 days, right?
            after = .init(year: self.year, month: self.month, day: self.day + 1)

        case days.upperBound:
            before = .init(year: self.year, month: self.month, day: self.day - 1)

            if  case .december = self.month
            {
                after = .init(year: self.year.successor, month: .january, day: 1)
            }
            else
            {
                after = .init(year: self.year, month: self.month.successor, day: 1)
            }

        default:
            before = .init(year: self.year, month: self.month, day: self.day - 1)
            after = .init(year: self.year, month: self.month, day: self.day + 1)
        }

        return (before, after)
    }
}
extension Timestamp.Date:CustomStringConvertible
{
    /// Formats the date as `yyyy-mm-dd`.
    ///
    /// To customize the separator, use ``description(separator:)``.
    @inlinable public
    var description:String { self.description(separator: "-") }
}
extension Timestamp.Date:LosslessStringConvertible
{
    /// Parses the date as `yyyy-mm-dd`.
    ///
    /// To customize the separator, use ``init(_:separator:)``.
    @inlinable public
    init?(_ description:String)
    {
        self.init(description, separator: "-")
    }
}
extension Timestamp.Date
{
    public
    init?(_ string:String, separator:Character)
    {
        self.init(string[...], separator: separator)
    }

    public
    init?(_ string:Substring, separator:Character = "-")
    {
        guard
        let hyphen:String.Index = string.firstIndex(of: "-"),
        let year:Timestamp.Year = .init(string[..<hyphen])
        else
        {
            return nil
        }

        let month:String.Index = string.index(after: hyphen)

        guard
        let hyphen:String.Index = string[month...].firstIndex(of: "-"),
        let month:Timestamp.Month = .init(string[month ..< hyphen])
        else
        {
            return nil
        }

        let day:String.Index = string.index(after: hyphen)

        guard
        let day:Int32 = .init(string[day...])
        else
        {
            return nil
        }

        self.init(year: year, month: month, day: day)
    }

    @inlinable public
    func description(separator:Character) -> String
    {
        "\(self.year)\(separator)\(self.mm)\(separator)\(self.dd)"
    }
}
extension Timestamp.Date
{
    @inlinable public
    var yyyymmdd:String { "\(self.year)\(self.mm)\(self.dd)" }

    @inlinable public
    var mm:String { "\(self.month.padded)" }

    @inlinable public
    var dd:String { self.day < 10 ? "0\(self.day)" : "\(self.day)" }
}
extension Timestamp.Date
{
    /// Same as calling ``Month/short(_:)`` on ``month``.
    @inlinable public
    func mon(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:   self.month.short(locale)
        }
    }

    /// Same as calling ``Month/long(_:)`` on ``month``.
    @inlinable public
    func month(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:   self.month.long(locale)
        }
    }

    @inlinable public
    func short(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:   "\(self.month.short(locale)) \(self.day), \(self.year)"
        }
    }
    @inlinable public
    func long(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:   "\(self.month.long(locale)) \(self.day), \(self.year)"
        }
    }
}
