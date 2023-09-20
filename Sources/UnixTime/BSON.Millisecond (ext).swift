import BSON

#if canImport(Glibc)
import struct Glibc.timespec

import func Glibc.clock_gettime
import var Glibc.CLOCK_REALTIME

#elseif canImport(Darwin)
import struct Darwin.timespec

import func Darwin.clock_gettime
import var Darwin.CLOCK_REALTIME
#endif

extension BSON.Millisecond
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

            let second:Int64 = .init(time.tv_sec)
            let nanoseconds:Int64 = .init(time.tv_nsec)

            return .init(1000 * second + nanoseconds / 1_000_000)
        }
    }
}
