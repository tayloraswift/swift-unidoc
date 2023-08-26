@frozen public
struct JSON:Sendable
{
    public
    var utf8:[UInt8]

    @inlinable internal
    init(utf8:[UInt8])
    {
        self.utf8 = utf8
    }
}
extension JSON:CustomStringConvertible
{
    public
    var description:String
    {
        .init(decoding: self.utf8, as: UTF8.self)
    }
}
extension JSON
{
    @inlinable internal
    subscript<Encoder>(as _:Encoder.Type = Encoder.self) -> Encoder where Encoder:JSONEncoder
    {
        _read
        {
            yield .empty
        }
        _modify
        {
            var encoder:Encoder = .move(&self)
            defer { self = encoder.move() }
            yield &encoder
        }
    }
}
extension JSON
{
    @inlinable public static
    func array(
        with encode:(inout ArrayEncoder) async throws -> Void) async rethrows -> Self
    {
        var encoder:ArrayEncoder = .empty
        try await encode(&encoder)
        return encoder.move()
    }

    @inlinable public static
    func array(
        with encode:(inout ArrayEncoder) throws -> Void) rethrows -> Self
    {
        var encoder:ArrayEncoder = .empty
        try encode(&encoder)
        return encoder.move()
    }

    @inlinable public static
    func object<CodingKey>(
        encoding keys:CodingKey.Type = CodingKey.self,
        with encode:(inout ObjectEncoder<CodingKey>) throws -> Void) rethrows -> Self
    {
        var encoder:ObjectEncoder<CodingKey> = .empty
        try encode(&encoder)
        return encoder.move()
    }
}
