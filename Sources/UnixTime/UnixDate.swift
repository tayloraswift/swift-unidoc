@frozen public
struct UnixDate:Equatable, Hashable, Sendable
{
    public
    var index:Int64

    @inlinable internal
    init(daySinceEpoch index:Int64)
    {
        self.index = index
    }
}
extension UnixDate
{
    @inlinable public static
    func midnight(before instant:UnixInstant) -> Self
    {
        .init(daySinceEpoch: instant.second / 86_400)
    }

    @inlinable public
    init?(utc date:Timestamp.Date)
    {
        guard
        let instant:UnixInstant = .init(utc: .init(date: date))
        else
        {
            return nil
        }

        self = .midnight(before: instant)
    }
}
extension UnixDate:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.index < b.index }
}
extension UnixDate:Strideable
{
    @inlinable public
    func advanced(by days:Int) -> Self { .init(daySinceEpoch: index.advanced(by: days)) }

    @inlinable public
    func distance(to day:Self) -> Int { self.index.distance(to: day.index) }
}
