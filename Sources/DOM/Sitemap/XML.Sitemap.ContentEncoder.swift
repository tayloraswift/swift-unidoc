extension XML.Sitemap
{
    @frozen public
    struct ContentEncoder:StreamingEncoder
    {
        @usableFromInline internal
        var utf8:[UInt8]

        @inlinable internal
        init(utf8:[UInt8] = [])
        {
            self.utf8 = utf8
        }
    }
}
extension XML.Sitemap.ContentEncoder
{
    /// Writes a string or substring to the output stream, escaping spcial characters as needed.
    ///
    /// Unlike the HTML/SVG encoder, there is no dedicated protocol for things that can be
    /// written to a sitemap output.
    @inlinable public static
    func += (self:inout Self, string:some StringProtocol)
    {
        self.utf8 += string.utf8
    }

    @inlinable internal static
    func += (self:inout Self, utf8:some Sequence<UInt8>)
    {
        for codeunit:UInt8 in utf8
        {
            self.append(unescaped: codeunit)
        }
    }
}
//  These cannot be factored into protocols due to mutation of ``utf8``.
extension XML.Sitemap.ContentEncoder:DOM.ContentEncoder
{
    @usableFromInline internal
    typealias AttributeEncoder = XML.Sitemap.AttributeEncoder

    /// Appends a *raw* UTF-8 code unit to the output stream.
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.utf8.append(codeunit)
    }
}
extension XML.Sitemap.ContentEncoder
{
    /// Appends an *unescaped* UTF-8 code unit to the output stream.
    /// If the code unit is one of the ASCII characters `&` `<`, or `>`,
    /// this function replaces it with the corresponding XML entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        self.utf8 += DOM.UTF8.init(codeunit)
    }

    /// Writes an opening sitemap tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func open(_ tag:XML.Sitemap.Element,
        with yield:(inout XML.Sitemap.AttributeEncoder) -> () = { _ in })
    {
        self.emit(opening: tag, with: yield)
    }

    /// Writes a closing sitemap tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func close(_ tag:XML.Sitemap.Element)
    {
        self.emit(closing: tag)
    }
}
extension XML.Sitemap.ContentEncoder
{
    @inlinable public
    subscript(_ tag:XML.Sitemap.Element,
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag)
            encode(&self)
            self.close(tag)
        }
    }
    @inlinable public
    subscript(_ tag:XML.Sitemap.Element,
        attributes:(inout XML.Sitemap.AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag, with: attributes)
            encode(&self)
            self.close(tag)
        }
    }
}
