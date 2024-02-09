import MarkdownABI

extension MarkdownElementContext
{
    //  TODO: investigate if it is worthwhile to track `href` and `id` as separate instance
    //  properties.
    struct AttributeContext
    {
        private
        var current:Markdown.Bytecode.Attribute?
        private
        var buffer:[UInt8]

        var list:AttributeList

        init()
        {
            self.current = nil
            self.buffer = []
            self.list = .init()
        }
    }
}
extension MarkdownElementContext.AttributeContext
{
    mutating
    func buffer(utf8 codeunit:UInt8) -> Void?
    {
        self.current.map { _ in self.buffer.append(codeunit) }
    }
    /// Remove all attributes from the attribute context.
    mutating
    func clear()
    {
        self.current = nil
        self.buffer.removeAll(keepingCapacity: true)
        self.list.removeAll(keepingCapacity: true)
    }
    /// Closes the current attribute (if any), and appends it to the list of
    /// complete attributes, making it available for encoding.
    mutating
    func flush(beginning next:Markdown.Bytecode.Attribute?)
    {
        defer
        {
            self.current = next
        }
        if  let instruction:Markdown.Bytecode.Attribute = self.current
        {
            self.list.append(value: .init(decoding: self.buffer, as: Unicode.UTF8.self),
                as: instruction)
            self.buffer.removeAll(keepingCapacity: true)
        }
    }
}
extension MarkdownElementContext.AttributeContext:MarkdownAttributeContext
{
}
