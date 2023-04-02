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
        .init(decoding: self.encoder.utf8, as: Unicode.UTF8.self)
    }
}
extension HTML
{
    @inlinable internal mutating
    func emit(_ tag:some RawRepresentable<String>, with yield:(inout AttributeEncoder) -> ())
    {
        self.encoder.utf8.append(0x3C) // '<'
        self.encoder.utf8.append(contentsOf: tag.rawValue.utf8)
        yield(&self.encoder)
        self.encoder.utf8.append(0x3E) // '>'
    }
}
extension HTML
{
    @inlinable public mutating
    func open(_ tag:ContainerElement, with yield:(inout AttributeEncoder) -> () = { _ in })
    {
        self.emit(tag, with: yield)
    }
    @inlinable public mutating
    func append(escaped codeunit:UInt8)
    {
        self.encoder.utf8.append(codeunit)
    }
    @inlinable public mutating
    func append(unescaped codeunit:UInt8)
    {
        switch codeunit
        {
        case 0x26: // '&'
            self.encoder.utf8 += "&amp;".utf8
        case 0x3C: // '<'
            self.encoder.utf8 += "&lt;".utf8
        case 0x3E: // '>'
            self.encoder.utf8 += "&gt;".utf8
        
        case let literal:
            self.encoder.utf8.append(literal)
        }
    }
    @inlinable public mutating
    func close(_ tag:ContainerElement)
    {
        self.encoder.utf8.append(0x3C) // '<'
        self.encoder.utf8.append(0x2F) // '/'
        self.encoder.utf8.append(contentsOf: tag.rawValue.utf8)
        self.encoder.utf8.append(0x3E) // '>'
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
