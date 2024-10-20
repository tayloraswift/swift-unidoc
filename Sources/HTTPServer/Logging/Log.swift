#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Darwin)
@preconcurrency import Darwin
#endif

@frozen public
enum Log
{
    @inlinable public static
    subscript<String>(level:Level) -> String?
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
