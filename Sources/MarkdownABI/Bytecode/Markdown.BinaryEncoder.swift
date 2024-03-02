extension Markdown
{
    @frozen public
    struct BinaryEncoder
    {
        @usableFromInline internal
        var attribute:AttributeEncoder

        @inlinable internal
        init()
        {
            self.attribute = .init(bytecode: [])
        }
    }
}
extension Markdown.BinaryEncoder
{
    @inlinable public internal(set)
    var bytecode:Markdown.Bytecode
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
extension Markdown.BinaryEncoder
{
    @inlinable public static
    func += (self:inout Self, bytecode:Markdown.Bytecode)
    {
        self.bytecode.bytes += bytecode.bytes
    }

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

    @inlinable public mutating
    func call()
    {
        self.bytecode.write(marker: .call)
    }
}
extension Markdown.BinaryEncoder
{
    @inlinable public
    subscript(_ emission:Markdown.Bytecode.Emission,
        attributes:(inout Markdown.AttributeEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            attributes(&self.attribute)
            self.bytecode.write(emission)
        }
    }
    @inlinable public
    subscript(_ context:Markdown.Bytecode.Context,
        attributes:(inout Markdown.AttributeEncoder) -> (),
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
    subscript(_ context:Markdown.Bytecode.Context,
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
extension Markdown.BinaryEncoder
{
    /// Emits the UTF-8 contents of the assigned string, if non-nil, into
    /// this binary, framed by the specified context. The setter does nothing
    /// if the assigned value is nil; it will not create an empty context.
    /// The getter always returns nil.
    @inlinable public
    subscript<String>(_ context:Markdown.Bytecode.Context,
        attributes:(inout Markdown.AttributeEncoder) -> () = { _ in }) -> String?
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
