import BSON
import UnixTime

extension BSON.Millisecond
{
    @inlinable public
    init(_ unix:UnixInstant)
    {
        self.init(1000 * unix.second + unix.nanoseconds / 1_000_000)
    }

    @inlinable public static
    func now() -> Self
    {
        self.init(.now())
    }
}
