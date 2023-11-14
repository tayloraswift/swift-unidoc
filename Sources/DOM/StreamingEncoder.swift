@usableFromInline internal
protocol StreamingEncoder
{
    init(utf8:[UInt8])
    var utf8:[UInt8] { get set }
}
extension StreamingEncoder
{
    @inlinable internal
    subscript<Encoder>(as _:Encoder.Type) -> Encoder where Encoder:StreamingEncoder
    {
        _read
        {
            yield .empty
        }
        _modify
        {
            var encoder:Encoder = .move(&self.utf8)
            defer { self.utf8 = encoder.move() }
            yield &encoder
        }
    }
}
extension StreamingEncoder
{
    @inlinable internal static
    var empty:Self { .init(utf8: []) }
}
extension StreamingEncoder
{
    @inlinable internal static
    func move(_ utf8:inout [UInt8]) -> Self
    {
        defer { utf8 = [] }
        return .init(utf8: utf8)
    }

    @inlinable internal mutating
    func move() -> [UInt8]
    {
        defer { self.utf8 = [] }
        return self.utf8
    }
}
