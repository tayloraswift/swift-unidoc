extension Markdown.BinaryEncoder
{
    subscript<Value>(_ context:Markdown.Bytecode.Context,
        attributes:(inout Markdown.AttributeEncoder) -> () = { _ in }) -> Value?
        where Value:Markdown.TreeElement
    {
        get { nil }
        set (value)
        {
            if  let value:Value
            {
                self[context, attributes, content: value.emit(into:)]
            }
        }
    }
}
