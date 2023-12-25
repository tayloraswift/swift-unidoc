extension Timestamp
{
    @frozen public
    struct Components:Equatable, Hashable, Sendable
    {
        public
        var date:Date
        public
        var time:Time

        @inlinable public
        init(date:Date, time:Time = .midnight)
        {
            self.date = date
            self.time = time
        }
    }
}
extension Timestamp.Components
{
    /// Truncates the time component of the argument to midnight.
    ///
    /// This constructor is a shorthand for `init(date: self.date)`.
    @inlinable public static
    func date(_ self:Self) -> Self { .init(date: self.date) }
}
extension Timestamp.Components
{
    public
    init?(iso8601 string:String)
    {
        self.init(iso8601: string[...])
    }

    public
    init?(iso8601 string:Substring)
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
        let t:String.Index = string[day...].firstIndex(of: "T"),
        let day:Int32 = .init(string[day ..< t])
        else
        {
            return nil
        }

        let hour:String.Index = string.index(after: t)

        guard
        let colon:String.Index = string[hour...].firstIndex(of: ":"),
        let hour:Int32 = .init(string[hour ..< colon])
        else
        {
            return nil
        }

        let minute:String.Index = string.index(after: colon)

        guard
        let colon:String.Index = string[minute...].firstIndex(of: ":"),
        let minute:Int32 = .init(string[minute ..< colon])
        else
        {
            return nil
        }

        let second:String.Index = string.index(after: colon)

        guard
        let z:String.Index = string.indices.last, case "Z" = string[z],
        let second:Int32 = .init(string[second ..< z])
        else
        {
            return nil
        }

        //  Don’t bother validating the day of the month; that is not what this type is for.

        if  0 ..< 24 ~= hour,
            0 ..< 60 ~= minute,
            0 ... 60 ~= second
        {
            self.init(date: .init(year: year, month: month, day: day),
                time: .init(hour: hour, minute: minute, second: second))
        }
        else
        {
            return nil
        }
    }
}
extension Timestamp.Components
{
    @available(*, deprecated, renamed: "Date.yyyymmdd")
    @inlinable public
    var yyyymmdd:String { "\(self.date.yyyymmdd)" }

    @available(*, deprecated, renamed: "Date.mm")
    @inlinable public
    var MM:String { self.date.mm }

    @available(*, deprecated, renamed: "Date.dd")
    @inlinable public
    var DD:String { self.date.dd }

    @available(*, deprecated, renamed: "Time.hh")
    @inlinable public
    var hh:String { self.time.hh }

    @available(*, deprecated, renamed: "Time.mm")
    @inlinable public
    var mm:String { self.time.mm }

    @available(*, deprecated, renamed: "Time.ss")
    @inlinable public
    var ss:String { self.time.ss }

    @inlinable public
    var yyyymmddThhmmssZ:String
    {
        "\(self.date.yyyymmdd)T\(self.time.hh)\(self.time.mm)\(self.time.ss)Z"
    }
}
