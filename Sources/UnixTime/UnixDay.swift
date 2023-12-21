@frozen public
struct UnixDay:Equatable, Hashable, Sendable
{
    public
    var index:Int64

    @inlinable internal
    init(daySinceEpoch index:Int64)
    {
        self.index = index
    }
}
extension UnixDay
{
    @inlinable public static
    func midnight(before instant:UnixInstant) -> Self
    {
        .init(daySinceEpoch: instant.second / 86_400)
    }
}
extension UnixDay:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int64) { self = .init(daySinceEpoch: integerLiteral) }
}
extension UnixDay:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.index < b.index }
}
extension UnixDay:Strideable
{
    @inlinable public
    func advanced(by days:Int) -> Self { .init(daySinceEpoch: index.advanced(by: days)) }

    @inlinable public
    func distance(to day:Self) -> Int { self.index.distance(to: day.index) }
}
