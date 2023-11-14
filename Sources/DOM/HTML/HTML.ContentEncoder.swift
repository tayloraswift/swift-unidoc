extension HTML
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
extension HTML.ContentEncoder
{
    @inlinable internal static
    func += (self:inout Self, utf8:some Sequence<UInt8>)
    {
        for codeunit:UInt8 in utf8
        {
            self.append(unescaped: codeunit)
        }
    }
}
extension HTML.ContentEncoder:DOM.ContentEncoder
{
    @usableFromInline internal
    typealias AttributeEncoder = HTML.AttributeEncoder

    /// Appends a *raw* UTF-8 code unit to the output stream.
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.utf8.append(codeunit)
    }
}
extension HTML.ContentEncoder
{
    /// Appends an *unescaped* UTF-8 code unit to the output stream.
    /// If the code unit is one of the ASCII characters `&` `<`, or `>`,
    /// this function replaces it with the corresponding HTML entity.
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        self.utf8 += DOM.UTF8.init(codeunit)
    }
    /// Writes an opening HTML tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func open(_ tag:HTML.ContainerElement,
        with yield:(inout HTML.AttributeEncoder) -> () = { _ in })
    {
        self.emit(opening: tag, with: yield)
    }
    /// Writes a closing HTML tag to the output stream.
    ///
    /// This is a low-level interface. Prefer encoding with ``subscript(_:content:)``
    /// or ``subscript(_:_:content:)``.
    @inlinable public mutating
    func close(_ tag:HTML.ContainerElement)
    {
        self.emit(closing: tag)
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_ tag:HTML.ContainerElement,
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
    subscript(_ tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.open(tag, with: attributes)
            encode(&self)
            self.close(tag)
        }
    }
    @inlinable public
    subscript(_ tag:HTML.VoidElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.emit(opening: tag, with: attributes)
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_ tag:HTML.UnsafeElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.emit(opening: tag, with: attributes)
            self.emit(closing: tag)
        }
    }
    @inlinable public
    subscript(unsafe tag:HTML.UnsafeElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> String
    {
        get { "" }
        set(unsafe)
        {
            self.emit(opening: tag, with: attributes)
            self.utf8 += unsafe.utf8
            self.emit(closing: tag)
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript(_:SVG.Embedded,
        attributes:(inout SVG.AttributeEncoder) -> (),
        content encode:(inout SVG.ContentEncoder) -> ()) -> Void
    {
        mutating get
        {
            {
                $0.open(.svg, with: attributes)
                encode(&$0)
                $0.close(.svg)
            } (&self[as: SVG.ContentEncoder.self])
        }
    }
}
