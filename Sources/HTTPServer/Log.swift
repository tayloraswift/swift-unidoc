import Glibc

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
