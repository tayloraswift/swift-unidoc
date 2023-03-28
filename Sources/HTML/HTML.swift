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
        self.encoder.string
    }
}
extension HTML
{
    @inlinable internal mutating
    func emit(_ tag:some RawRepresentable<String>, with yield:(inout AttributeEncoder) -> ())
    {
        self.encoder.string.append("<")
        self.encoder.string.append(tag.rawValue)
        yield(&self.encoder)
        self.encoder.string.append(">")
    }
}
extension HTML
{
    @inlinable public mutating
    func close(_ tag:ContainerElement)
    {
        self.encoder.string.append("</")
        self.encoder.string.append(tag.rawValue)
        self.encoder.string.append(">")
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
