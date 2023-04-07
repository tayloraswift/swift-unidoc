import MarkdownABI

extension MarkdownBinary
{
    @available(*, unavailable, message: """
        Converting a markdown tree into a binary with no semantics is not probably not
        what you want to do. (If you really do want to do this, pass `tree.emit(into:)`
        to the ``init(with:)`` initializer.)
        """)
    public
    init(from tree:MarkdownTree)
    {
        self.init(with: tree.emit(into:))
    }

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
