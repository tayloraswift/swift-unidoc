import HTML
import MarkdownABI

extension MarkdownTextContext
{
    struct AttributeContext
    {
        private
        var current:Void?

        init()
        {
            self.current = nil
        }
    }
}
extension MarkdownTextContext.AttributeContext:MarkdownAttributeContext
{
    mutating
    func append(value _:String, as _:MarkdownBytecode.Attribute)
    {
    }

    func buffer(utf8 codeunit:UInt8) -> Void?
    {
        self.current
    }

    mutating
    func flush(beginning next:MarkdownBytecode.Attribute?)
    {
        self.current = next.map { _ in }
    }

    mutating
    func clear()
    {
        self.current = nil
    }
}
