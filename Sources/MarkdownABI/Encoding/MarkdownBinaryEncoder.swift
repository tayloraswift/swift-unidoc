@frozen public
struct MarkdownBinaryEncoder
{
    @usableFromInline internal
    var attribute:MarkdownAttributeEncoder

    @inlinable internal
    init()
    {
        self.attribute = .init(bytecode: [])
    }
}
extension MarkdownBinaryEncoder
{
    @inlinable public internal(set)
    var bytecode:MarkdownBytecode
    {
        _read
        {
            yield  self.attribute.bytecode
        }
        _modify
        {
            yield &self.attribute.bytecode
        }
    }
}
extension MarkdownBinaryEncoder
{
    @inlinable public static
    func += (self:inout Self, codepoint:Unicode.Scalar)
    {
        self.bytecode.write(utf8: codepoint.utf8)
    }
    @inlinable public static
    func += (self:inout Self, character:Character)
    {
        self.bytecode.write(utf8: character.utf8)
    }
    @inlinable public static
    func += (self:inout Self, text:some StringProtocol)
    {
        self.bytecode.write(text: text)
    }
    @inlinable public static
    func += (self:inout Self, utf8:some Sequence<UInt8>)
    {
        self.bytecode.write(utf8: utf8)
    }
    @inlinable public static
    func &= (self:inout Self, reference:Int)
    {
        self.bytecode.write(reference: reference)
    }
}
extension MarkdownBinaryEncoder
{
    @inlinable public
    subscript(_ emission:MarkdownBytecode.Emission,
        attributes:(inout MarkdownAttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.attribute)
            self.bytecode.write(emission)
        }
    }
    @inlinable public
    subscript(_ context:MarkdownBytecode.Context,
        attributes:(inout MarkdownAttributeEncoder) -> (),
        content encode:(inout Self) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.attribute)
            self.bytecode.write(context)
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
            self.bytecode.write(context)
            encode(&self)
            self.bytecode.write(marker: .pop)
        }
    }
}
extension MarkdownBinaryEncoder
{
    /// Emits the UTF-8 contents of the assigned string, if non-nil, into
    /// this binary, framed by the specified context. The setter does nothing
    /// if the assigned value is nil; it will not create an empty context.
    /// The getter always returns nil.
    @inlinable public
    subscript<String>(_ context:MarkdownBytecode.Context,
        attributes:(inout MarkdownAttributeEncoder) -> () = { _ in }) -> String?
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
                self[context, attributes] { $0 += text }
            }
        }
    }
}
