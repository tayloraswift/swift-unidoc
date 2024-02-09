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
    func buffer(utf8 codeunit:UInt8) -> Void?
    {
        self.current
    }

    mutating
    func flush(beginning next:Markdown.Bytecode.Attribute?)
    {
        self.current = next.map { _ in }
    }

    mutating
    func clear()
    {
        self.current = nil
    }
}
