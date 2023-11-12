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
//  These cannot be factored into protocols due to mutation of ``utf8``.
extension XML.Sitemap.ContentEncoder
{
    @inlinable internal mutating
    func emit(opening tag:some RawRepresentable<String>,
        with yield:(inout XML.Sitemap.AttributeEncoder) -> ())
    {
        self.utf8.append(0x3C) // '<'
        self.utf8.append(contentsOf: tag.rawValue.utf8)
        yield(&self[as: XML.Sitemap.AttributeEncoder.self])
        self.utf8.append(0x3E) // '>'
    }

    @inlinable internal mutating
    func emit(closing tag:some RawRepresentable<String>)
    {
        self.utf8.append(0x3C) // '<'
        self.utf8.append(0x2F) // '/'
        self.utf8.append(contentsOf: tag.rawValue.utf8)
        self.utf8.append(0x3E) // '>'
    }
}
extension XML.Sitemap.ContentEncoder
{
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
    /// Appends a *raw* UTF-8 code unit to the output stream.
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.utf8.append(codeunit)
    }
    /// Appends an *unescaped* UTF-8 code unit to the output stream.
    /// If the code unit is one of the ASCII characters `&` `<`, or `>`,
    /// this function replaces it with the corresponding XML entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        self.utf8 += DOM.UTF8.init(codeunit)
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
