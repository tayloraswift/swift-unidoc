extension Duration
{
    @frozen public
    struct DynamicFormat
    {
        public
        var scalar:Int64
        public
        var unit:Unit

        @inlinable public
        init(scalar:Int64, unit:Unit)
        {
            self.scalar = scalar
            self.unit = unit
        }
    }
}
extension Duration.DynamicFormat
{
    @inlinable public
    init(seconds:Int64)
    {
        if      seconds < 2 * 60
        {
            self.init(scalar: seconds, unit: .seconds)
        }
        else if seconds < 2 * 60 * 60
        {
            self.init(scalar: seconds / 60, unit: .minutes)
        }
        else if seconds < 2 * 24 * 3600
        {
            self.init(scalar: seconds / 3600, unit: .hours)
        }
        else
        {
            self.init(scalar: seconds / 86400, unit: .days)
        }
    }

    @inlinable public
    init(truncating duration:Duration)
    {
        self.init(seconds: duration.components.seconds)
    }
}
extension Duration.DynamicFormat
{
    @inlinable public
    var short:String
    {
        switch self.unit
        {
        case .seconds:  "\(self.scalar) s"
        case .minutes:  "\(self.scalar) m"
        case .hours:    "\(self.scalar) h"
        case .days:     "\(self.scalar) d"
        }
    }
}
extension Duration.DynamicFormat:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch (self.scalar, self.unit)
        {
        case (1,            .seconds):  "1 second"
        case (let scalar,   .seconds):  "\(scalar) seconds"
        case (1,            .minutes):  "1 minute"
        case (let scalar,   .minutes):  "\(scalar) minutes"
        case (1,            .hours):    "1 hour"
        case (let scalar,   .hours):    "\(scalar) hours"
        case (1,            .days):     "1 day"
        case (let scalar,   .days):     "\(scalar) days"
        }
    }
}
