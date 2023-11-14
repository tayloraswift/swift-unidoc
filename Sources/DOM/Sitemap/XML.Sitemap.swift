extension XML
{
    @frozen public
    struct Sitemap
    {
        public
        var encoder:ContentEncoder

        /// Creates a completely empty sitemap.
        @inlinable public
        init()
        {
            self.encoder = .init()
        }
    }
}
extension XML.Sitemap
{
    /// Encodes an XML fragment with the provided closure.
    ///
    /// To encode a complete document, use ``document(with:)``.
    @inlinable internal
    init(with encode:(inout ContentEncoder) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.encoder)
    }
}
extension XML.Sitemap:ExpressibleByStringLiteral
{
    /// Creates a sitemap document containing the **exact** contents of the given
    /// string literal.
    ///
    /// Use this with caution. This initializer performs no escaping or validation!
    @inlinable public
    init(stringLiteral:String)
    {
        self.init { $0.utf8 = [UInt8].init(stringLiteral.utf8) }
    }
}
extension XML.Sitemap
{
    @inlinable public
    var utf8:[UInt8] { self.encoder.utf8 }
}
extension XML.Sitemap:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(decoding: self.encoder.utf8, as: Unicode.UTF8.self)
    }
}
