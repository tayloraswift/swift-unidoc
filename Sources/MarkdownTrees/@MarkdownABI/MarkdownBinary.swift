import MarkdownABI

extension MarkdownBinary
{
    @inlinable public
    subscript<Value>(_ context:MarkdownBytecode.Context,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> Value?
        where Value:MarkdownBinaryConvertibleElement
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Value
            {
                self[context, attributes, content: value.emit(into:)]
            }
        }
    }
}
