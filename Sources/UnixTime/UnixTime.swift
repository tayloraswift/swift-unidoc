
#if canImport(Glibc)
import struct Glibc.timespec

import func Glibc.clock_gettime
import var Glibc.CLOCK_REALTIME

#elseif canImport(Darwin)
import struct Darwin.timespec

import func Darwin.clock_gettime
import var Darwin.CLOCK_REALTIME
#else
#error("Platform doesn’t support 'clock_gettime'")
#endif

@frozen public
struct UnixTime:Equatable, Hashable, Sendable
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
extension UnixTime
{
    @inlinable public static
    func second(_ second:Int64, plus nanoseconds:Int64 = 0) -> Self
    {
        return .init(second: second, nanoseconds: nanoseconds)
    }
}
extension UnixTime:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.second, lhs.nanoseconds) < (rhs.second, rhs.nanoseconds)
    }
}
extension UnixTime
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
extension UnixTime
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
