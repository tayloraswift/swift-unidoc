@frozen public
struct MarkdownBinary
{
    @usableFromInline internal
    var encoder:AttributeEncoder

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.encoder = .init(bytecode: .init(bytes: bytes))
    }
}
extension MarkdownBinary
{
    @inlinable public
    init(with encode:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try encode(&self)
    }
}
extension MarkdownBinary
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.bytecode.bytes
    }

    @inlinable public internal(set)
    var bytecode:MarkdownBytecode
    {
        _read
        {
            yield  self.encoder.bytecode
        }
        _modify
        {
            yield &self.encoder.bytecode
        }
    }
}
extension MarkdownBinary
{
    @inlinable public mutating
    func write(text:some StringProtocol)
    {
        self.bytecode.write(text: text)
    }
    @inlinable public mutating
    func write(reference:UInt32)
    {
        self.bytecode.write(reference: .init(id: reference))
    }
    @inlinable public mutating
    func fold()
    {
        self.bytecode.write(marker: .fold)
    }
}
extension MarkdownBinary
{
    @inlinable public
    subscript(_ emission:MarkdownBytecode.Emission,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.encoder)
            self.bytecode.write(instruction: emission)
        }
    }
    @inlinable public
    subscript(_ context:MarkdownBytecode.Context,
        attributes:(inout AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.encoder)
            self.bytecode.write(instruction: context)
            encode(&self)
            self.bytecode.write(marker: .pop)
        }
    }
    @inlinable public
    subscript(_ context:MarkdownBytecode.Context,
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.bytecode.write(instruction: context)
            encode(&self)
            self.bytecode.write(marker: .pop)
        }
    }
}
extension MarkdownBinary
{
    /// Emits the UTF-8 contents of the assigned string, if non-nil, into
    /// this binary, framed by the specified context. The setter does nothing
    /// if the assigned value is nil; it will not create an empty context.
    /// The getter always returns nil.
    @inlinable public
    subscript<String>(_ context:MarkdownBytecode.Context,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> String?
        where String:StringProtocol
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self[context, attributes] { $0.write(text: text) }
            }
        }
    }
}
