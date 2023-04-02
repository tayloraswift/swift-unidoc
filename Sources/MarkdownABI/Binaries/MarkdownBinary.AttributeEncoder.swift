extension MarkdownBinary
{
    @frozen public
    struct AttributeEncoder
    {
        @usableFromInline internal
        var bytecode:MarkdownBytecode

        @inlinable internal
        init(bytecode:MarkdownBytecode = .init())
        {
            self.bytecode = bytecode
        }
    }
}
extension MarkdownBinary.AttributeEncoder
{
    /// Serializes an empty attribute, if the assigned boolean is true.
    /// Does nothing if it is false. The getter always returns false.
    @inlinable public
    subscript(attribute:MarkdownBytecode.Attribute) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[attribute] = bool ? "" : nil
        }
    }
    @inlinable public
    subscript(attribute:MarkdownBytecode.Attribute) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if let text:String
            {
                self.bytecode.write(instruction: attribute)
                self.bytecode.write(text: text)
            }
        }
    }
}
