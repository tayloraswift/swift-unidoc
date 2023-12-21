extension Timestamp
{
    @frozen public
    struct Date:Equatable, Hashable, Sendable
    {
        public
        var year:Int32
        public
        var month:Int32
        public
        var day:Int32

        @inlinable public
        init(year:Int32, month:Int32, day:Int32)
        {
            self.year = year
            self.month = month
            self.day = day
        }
    }
}
extension Timestamp.Date
{
    @inlinable public
    var yyyymmdd:String { "\(self.year)\(self.mm)\(self.dd)" }

    @inlinable public
    var mm:String { self.month < 10 ? "0\(self.month)" : "\(self.month)" }

    @inlinable public
    var dd:String { self.day < 10 ? "0\(self.day)" : "\(self.day)" }
}
extension Timestamp.Date
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
