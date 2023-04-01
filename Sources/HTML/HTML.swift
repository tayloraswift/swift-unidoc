@frozen public
struct HTML
{
    @usableFromInline internal
    var encoder:AttributeEncoder

    @inlinable public
    init()
    {
        self.encoder = .init()
    }
}
extension HTML
{
    @inlinable public
    var utf8:[UInt8]
    {
        _read
        {
            yield  self.encoder.utf8
        }
        _modify
        {
            yield &self.encoder.utf8
        }
    }

    @inlinable public
    init(with encode:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try encode(&self)
    }
}
extension HTML:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(decoding: self.utf8, as: Unicode.UTF8.self)
    }
}
extension HTML
{
    @inlinable internal mutating
    func emit(_ tag:some RawRepresentable<String>, with yield:(inout AttributeEncoder) -> ())
    {
        self.utf8.append(0x3C) // '<'
        self.utf8.append(contentsOf: tag.rawValue.utf8)
        yield(&self.encoder)
        self.utf8.append(0x3E) // '>'
    }
}
extension HTML
{
    @inlinable public mutating
    func close(_ tag:ContainerElement)
    {
        self.utf8.append(0x3C) // '<'
        self.utf8.append(0x2F) // '/'
        self.utf8.append(contentsOf: tag.rawValue.utf8)
        self.utf8.append(0x3E) // '>'
    }
    @inlinable public mutating
    func open(_ tag:ContainerElement, with yield:(inout AttributeEncoder) -> () = { _ in })
    {
        self.emit(tag, with: yield)
    }
}
extension HTML
{
    @inlinable public
    subscript(_ tag:ContainerElement,
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
    subscript(_ tag:ContainerElement,
        attributes:(inout AttributeEncoder) -> (),
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
    subscript(_ tag:VoidElement,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.emit(tag, with: attributes)
        }
    }
}
