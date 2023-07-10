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
extension HTML
{
    /// Encodes an HTML document with the provided closure, which includes
    /// the prefixed `<!DOCTYPE html>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var html:Self = .init
        {
            $0.utf8 += "<!DOCTYPE html>".utf8
        }
        try encode(&html.encoder)
        return html
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
