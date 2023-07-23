@frozen public
struct MarkdownAttributeEncoder
{
    @usableFromInline internal
    var bytecode:MarkdownBytecode

    @inlinable internal
    init(bytecode:MarkdownBytecode)
    {
        self.bytecode = bytecode
    }
}
extension MarkdownAttributeEncoder
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
                self.bytecode.write(attribute)
                self.bytecode.write(text: text)
            }
        }
    }
    @inlinable public
    subscript(attribute:MarkdownBytecode.Attribute) -> Int?
    {
        get
        {
            nil
        }
        set(reference)
        {
            if  let reference:Int
            {
                self.bytecode.write(attribute, reference: reference)
            }
        }
    }
}
