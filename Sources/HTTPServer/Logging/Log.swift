#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Darwin)
@preconcurrency import Darwin
#endif

import HTTP

@frozen public
enum Log
{
    @inlinable public static
    subscript<String>(level:HTTP.LogLevel) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            value.map
            {
                print("\(level): ", terminator: "")
                print($0)
                fflush(stdout)
            }
        }
    }
}
