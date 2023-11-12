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
extension XML.Sitemap
{
    /// Encodes an XML document with the provided closure, which includes
    /// the prefixed `<?xml version="1.0" encoding="UTF-8"?>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var xml:Self = .init
        {
            $0.utf8 += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>".utf8
        }
        try encode(&xml.encoder)
        return xml
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
