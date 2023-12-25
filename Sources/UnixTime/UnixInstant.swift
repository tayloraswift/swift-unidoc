#if canImport(Glibc)
import struct Glibc.timespec
import struct Glibc.tm

import func Glibc.clock_gettime
import var Glibc.CLOCK_REALTIME
import func Glibc.gmtime_r
import func Glibc.timegm

#elseif canImport(Darwin)
import struct Darwin.timespec
import struct Darwin.tm

import func Darwin.clock_gettime
import var Darwin.CLOCK_REALTIME
import func Darwin.gmtime_r
import func Darwin.timegm
#else
#error("Platform doesn’t support 'clock_gettime'")
#endif

@frozen public
struct UnixInstant:Equatable, Hashable, Sendable
{
    public
    var second:Int64
    public
    let nanoseconds:Int64

    @inlinable internal
    init(second:Int64, nanoseconds:Int64)
    {
        self.second = second
        self.nanoseconds = nanoseconds
    }
}
extension UnixInstant
{
    @available(*, deprecated, renamed: "date(_:)")
    @inlinable public static
    func day(_ date:UnixDate) -> Self
    {
        .date(date)
    }

    @inlinable public static
    func date(_ date:UnixDate) -> Self
    {
        .init(second: date.index * 86_400, nanoseconds: 0)
    }

    @inlinable public static
    func second(_ second:Int64, plus nanoseconds:Int64 = 0) -> Self
    {
        .init(second: second, nanoseconds: nanoseconds)
    }

    @inlinable public static
    func millisecond(_ millisecond:Int64) -> Self
    {
        let (second, milliseconds):(Int64, Int64) = millisecond.quotientAndRemainder(
            dividingBy: 1000)

        return .init(second: second, nanoseconds: milliseconds * 1_000_000)
    }

    @inlinable public
    init?(utc timestamp:Timestamp.Components)
    {
        var time:tm = .init(
            tm_sec:     timestamp.time.second,
            tm_min:     timestamp.time.minute,
            tm_hour:    timestamp.time.hour,
            tm_mday:    timestamp.date.day,
            tm_mon:     timestamp.date.month.rawValue - 1, // month in range 0 ... 11 !
            tm_year:    timestamp.date.year.rawValue - 1900,
            tm_wday:    -1,
            tm_yday:    -1,
            tm_isdst:   0,

            tm_gmtoff:  0,
            tm_zone:    nil)

        switch withUnsafeMutablePointer(to: &time, timegm)
        {
        case -1:            return nil
        case let second:    self.init(second: Int64.init(second), nanoseconds: 0)
        }
    }

    public
    var timestamp:Timestamp?
    {
        var segmented:tm = .init(
            tm_sec:     -1,
            tm_min:     -1,
            tm_hour:    -1,
            tm_mday:    -1,
            tm_mon:     -1, // month in range 0 ... 11 !
            tm_year:    -1,
            tm_wday:    -1,
            tm_yday:    -1,
            tm_isdst:   0,

            tm_gmtoff:  0,
            tm_zone:    nil)

        let second:Int = .init(self.second)

        guard withUnsafePointer(to: second, { gmtime_r($0, &segmented) }) != nil,
        let weekday:Timestamp.Weekday = .init(rawValue: Int.init(segmented.tm_wday)),
        let month:Timestamp.Month = .init(rawValue: segmented.tm_mon + 1)
        else
        {
            return nil
        }

        return .init(weekday: weekday,
            date: .init(year: .init(rawValue: segmented.tm_year + 1900),
                month: month,
                day: segmented.tm_mday),
            time: .init(hour: segmented.tm_hour,
                minute: segmented.tm_min,
                second: segmented.tm_sec))
    }
}
extension UnixInstant:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.second, lhs.nanoseconds) < (rhs.second, rhs.nanoseconds)
    }
}
extension UnixInstant
{
    @inlinable public static
    func - (after:Self, before:Self) -> Duration
    {
        let seconds:Int64 = after.second - before.second
        let nanoseconds:Int64 = after.nanoseconds - before.nanoseconds
        //  This initializer will automatically normalize negative attoseconds.
        return .init(
            secondsComponent: seconds,
            attosecondsComponent: 1_000_000_000 * nanoseconds)
    }
}
extension UnixInstant
{
    public static
    func now() -> Self
    {
        withUnsafeTemporaryAllocation(of: timespec.self, capacity: 1)
        {
            guard clock_gettime(CLOCK_REALTIME, $0.baseAddress) == 0
            else
            {
                fatalError("system clock unavailable! (CLOCK_REALTIME)")
            }

            let time:timespec = $0[0]
            return .second(Int64.init(time.tv_sec), plus: Int64.init(time.tv_nsec))
        }
    }
}
