@frozen public
struct HTML
{
    public
    var encoder:ContentEncoder

    /// Creates a completely empty HTML document.
    @inlinable public
    init()
    {
        self.encoder = .init()
    }
}
extension HTML
{
    /// Encodes an HTML fragment with the provided closure.
    ///
    /// To encode a complete document, use ``document(with:)``.
    @inlinable public
    init(with encode:(inout ContentEncoder) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.encoder)
    }
}
extension HTML:ExpressibleByStringLiteral
{
    /// Creates an HTML document containing the **exact** contents of the given
    /// string literal.
    ///
    /// Use this with caution. This initializer performs no escaping or validation!
    @inlinable public
    init(stringLiteral:String)
    {
        self.init { $0.utf8 = [UInt8].init(stringLiteral.utf8) }
    }
}
extension HTML
{
    @inlinable public
    var utf8:[UInt8] { self.encoder.utf8 }
}
extension HTML:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(decoding: self.encoder.utf8, as: Unicode.UTF8.self)
    }
}
