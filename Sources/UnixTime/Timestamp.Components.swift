extension Timestamp
{
    @frozen public
    struct Components:Equatable, Hashable, Sendable
    {
        public
        var year:Int32
        public
        var month:Int32
        public
        var day:Int32
        public
        var hour:Int32
        public
        var minute:Int32
        public
        var second:Int32

        @inlinable public
        init(year:Int32, month:Int32, day:Int32, hour:Int32, minute:Int32, second:Int32)
        {
            self.year = year
            self.month = month
            self.day = day
            self.hour = hour
            self.minute = minute
            self.second = second
        }
    }
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
        let year:Int32 = .init(string[..<hyphen])
        else
        {
            return nil
        }

        let month:String.Index = string.index(after: hyphen)

        guard
        let hyphen:String.Index = string[month...].firstIndex(of: "-"),
        let month:Int32 = .init(string[month ..< hyphen])
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

        if  1 ... 12 ~= month,
            1 ... 31 ~= day,
            0 ..< 24 ~= hour,
            0 ..< 60 ~= minute,
            0 ... 60 ~= second
        {
            self.init(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second)
        }
        else
        {
            return nil
        }
    }
}
extension Timestamp.Components
{
    @inlinable public
    var yyyymmdd:String
    {
        "\(self.year)\(self.MM)\(self.DD)"
    }

    @inlinable public
    var MM:String
    {
        self.month < 10 ? "0\(self.month)" : "\(self.month)"
    }

    @inlinable public
    var DD:String
    {
        self.day < 10 ? "0\(self.day)" : "\(self.day)"
    }

    @inlinable public
    var hh:String
    {
        self.hour < 10 ? "0\(self.hour)" : "\(self.hour)"
    }

    @inlinable public
    var mm:String
    {
        self.minute < 10 ? "0\(self.minute)" : "\(self.minute)"
    }

    @inlinable public
    var ss:String
    {
        self.second < 10 ? "0\(self.second)" : "\(self.second)"
    }

    @inlinable public
    var yyyymmddThhmmssZ:String
    {
        "\(self.yyyymmdd)T\(self.hh)\(self.mm)\(self.ss)Z"
    }
}
extension Timestamp.Components
{
    @inlinable public
    func mon(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:
            switch self.month
            {
            case  1:    "Jan"
            case  2:    "Feb"
            case  3:    "Mar"
            case  4:    "Apr"
            case  5:    "May"
            case  6:    "Jun"
            case  7:    "Jul"
            case  8:    "Aug"
            case  9:    "Sep"
            case 10:    "Oct"
            case 11:    "Nov"
            case 12:    "Dec"
            case  _:    "???"
            }
        }
    }

    @inlinable public
    func month(_ locale:Timestamp.Locale) -> String
    {
        switch locale
        {
        case .en:
            switch self.month
            {
            case  1:    "January"
            case  2:    "February"
            case  3:    "March"
            case  4:    "April"
            case  5:    "May"
            case  6:    "June"
            case  7:    "July"
            case  8:    "August"
            case  9:    "September"
            case 10:    "October"
            case 11:    "November"
            case 12:    "December"
            case  _:    "?"
            }
        }
    }
}
