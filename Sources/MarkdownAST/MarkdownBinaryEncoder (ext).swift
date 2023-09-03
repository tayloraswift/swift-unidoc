import MarkdownABI

extension MarkdownBinaryEncoder
{
    subscript<Value>(_ context:MarkdownBytecode.Context,
        attributes:(inout MarkdownAttributeEncoder) -> () = { _ in }) -> Value?
        where Value:MarkdownElement
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
