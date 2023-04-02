import HTMLRendering

@rethrows public
protocol MarkdownExecutable
{
    func fill(html:inout HTML, with reference:UInt32) rethrows

    var bytecode:MarkdownBytecode { get }
}
extension MarkdownExecutable where Self:RenderableAsHTML
{
    public
    func render(to html:inout HTML) throws
    {
        var attributes:MarkdownAttributeContext = .init()
        var stack:[MarkdownElementContext] = []

        for instruction:MarkdownInstruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw MarkdownExecutionError.invalid
            
            case .attribute(let attribute):
                attributes.flush()
                attributes.current = (attribute, [])
            
            case .emit(let element):
                attributes.flush()
                html.emit(element: element, with: attributes)
                attributes.clear()
            
            case .push(let element):
                attributes.flush()

                let context:MarkdownElementContext = .init(from: element,
                    attributes: &attributes)
                
                html.open(context: context, with: attributes)

                stack.append(context)
                attributes.clear()
            
            case .pop:
                guard let element:MarkdownElementContext = stack.popLast()
                else
                {
                    throw MarkdownExecutionError.illegal
                }

                if case nil = attributes.current
                {
                    html.close(context: element)
                }
                else
                {
                    throw MarkdownExecutionError.attributes(preceding: .pop)
                }
            
            case .reference(let reference):
                if case nil = attributes.current
                {
                    try self.fill(html: &html, with: reference)
                }
                else
                {
                    throw MarkdownExecutionError.attributes(preceding: .reference)
                }
            
            case .utf8(let codeunit):
                guard case nil = attributes.current?.utf8.append(codeunit)
                else
                {
                    continue
                }
                //  Not in an attribute context.
                if case .transparent? = stack.last
                {
                    html.append(escaped: codeunit)
                }
                else
                {
                    html.append(unescaped: codeunit)
                }

            }
        }
        if !stack.isEmpty
        {
            throw MarkdownExecutionError.incomplete
        }
    }
}
