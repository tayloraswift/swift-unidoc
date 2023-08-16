@usableFromInline internal
protocol JSONEncoder
{
    static
    func move(_ json:inout JSON) -> Self

    mutating
    func move() -> JSON
}
extension JSONEncoder
{
    @inlinable internal static
    var empty:Self
    {
        var json:JSON = .init(utf8: [])
        return .move(&json)
    }
}
