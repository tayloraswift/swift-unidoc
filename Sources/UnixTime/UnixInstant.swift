#if canImport(Glibc)
import struct Glibc.timespec
import struct Glibc.tm

import func Glibc.clock_gettime
import func Glibc.timegm
import var Glibc.CLOCK_REALTIME

#elseif canImport(Darwin)
import struct Darwin.timespec
import struct Darwin.tm

import func Darwin.clock_gettime
import func Darwin.timegm
import var Darwin.CLOCK_REALTIME
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
    @inlinable public static
    func second(_ second:Int64, plus nanoseconds:Int64 = 0) -> Self
    {
        return .init(second: second, nanoseconds: nanoseconds)
    }

    @inlinable public
    init?(timestamp:Timestamp)
    {
        var time:tm = .init(
            tm_sec:     timestamp.second,
            tm_min:     timestamp.minute,
            tm_hour:    timestamp.hour,
            tm_mday:    timestamp.day,
            tm_mon:     timestamp.month - 1, // month in range 0 ... 11 !
            tm_year:    timestamp.year - 1900,
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