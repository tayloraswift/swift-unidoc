import BSON

extension BSON.Millisecond:UnixInstant
{
    @inlinable public static
    func unix(second:Int64, plus nanoseconds:Int64) -> Self
    {
        .init(1000 * second + nanoseconds / 1_000_000)
    }
}
