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
    func write(reference:MarkdownInstruction.Reference)
    {
        self.bytecode.write(instruction: reference)
    }
}
extension MarkdownBinary
{
    @inlinable public
    subscript(_ element:MarkdownInstruction.Emit,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.encoder)
            self.bytecode.write(instruction: element)
        }
    }
    @inlinable public
    subscript(_ element:MarkdownInstruction.Push,
        attributes:(inout AttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.encoder)
            self.bytecode.write(instruction: element)
            encode(&self)
            self.bytecode.write(instruction: .pop)
        }
    }
    @inlinable public
    subscript(_ element:MarkdownInstruction.Push,
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            self.bytecode.write(instruction: element)
            encode(&self)
            self.bytecode.write(instruction: .pop)
        }
    }
}
