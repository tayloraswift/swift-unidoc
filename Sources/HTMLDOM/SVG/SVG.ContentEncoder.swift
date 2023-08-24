extension SVG
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
extension SVG.ContentEncoder
{
    @inlinable internal mutating
    func emit(opening tag:some RawRepresentable<String>,
        with yield:(inout SVG.AttributeEncoder) -> ())
    {
        self.utf8.append(0x3C) // '<'
        self.utf8.append(contentsOf: tag.rawValue.utf8)
        yield(&self[as: SVG.AttributeEncoder.self])
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
extension SVG.ContentEncoder
{
    /// Writes an opening SVG tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func open(_ tag:SVG.ContainerElement,
        with yield:(inout SVG.AttributeEncoder) -> () = { _ in })
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
    /// this function replaces it with the corresponding SVG entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        switch codeunit
        {
        case 0x26: // '&'
            self.utf8 += "&amp;".utf8
        case 0x3C: // '<'
            self.utf8 += "&lt;".utf8
        case 0x3E: // '>'
            self.utf8 += "&gt;".utf8

        case let literal:
            self.utf8.append(literal)
        }
    }
    /// Writes a closing SVG tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func close(_ tag:SVG.ContainerElement)
    {
        self.emit(closing: tag)
    }
}
extension SVG.ContentEncoder
{
    @inlinable public
    subscript(_ tag:SVG.ContainerElement,
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
    subscript(_ tag:SVG.ContainerElement,
        attributes:(inout SVG.AttributeEncoder) -> (),
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
