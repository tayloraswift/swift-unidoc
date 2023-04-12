import HTML

@rethrows public
protocol MarkdownExecutable
{
    var bytecode:MarkdownBytecode { get }

    func fold(html:inout HTML) throws
    func fill(html:inout HTML, with reference:UInt32) throws
}
extension MarkdownExecutable
{
    /// Inserts a newline.
    public
    func fold(html:inout HTML)
    {
        html.append(escaped: 0x0A)
    }
    /// Renders a placeholder `code` element describing the reference.
    public
    func fill(html:inout HTML, with reference:UInt32)
    {
        html[.code] = "<reference = \(reference)>"
    }
}
extension MarkdownExecutable
{
    /// Runs this markdown executable and renders its output to the HTML argument.
    /// If an error occurs, stops execution and returns the error, otherwise
    /// returns nil if successful. This function always closes any HTML elements
    /// it creates, even on error.
    public
    func render(to html:inout HTML) rethrows -> MarkdownExecutionError?
    {
        var attributes:MarkdownAttributeContext = .init()
        var stack:[MarkdownElementContext] = []

        defer
        {
            for context:MarkdownElementContext in stack.reversed()
            {
                html.close(context: context)
            }
        }

        for instruction:MarkdownInstruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                return .invalid
            
            case .attribute(let attribute):
                attributes.flush()
                attributes.current = (attribute, [])
            
            case .emit(let element):
                attributes.flush()
                html.emit(element: element, with: attributes)
                attributes.clear()
            
            case .fold:
                try self.fold(html: &html)
            
            case .push(let element):
                attributes.flush()

                let context:MarkdownElementContext = .init(from: element,
                    attributes: &attributes)
                
                html.open(context: context, with: attributes)

                stack.append(context)
                attributes.clear()
            
            case .pop:
                if let context:MarkdownElementContext = stack.popLast()
                {
                    html.close(context: context)
                }
                else
                {
                    return .illegal
                }

                guard case nil = attributes.current
                else
                {
                    return .attributes(preceding: .pop)
                }
            
            case .reference(let reference):
                guard case nil = attributes.current
                else
                {
                    return .attributes(preceding: .reference)
                }

                try self.fill(html: &html, with: reference)
            
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
        return stack.isEmpty ? nil : .incomplete
    }
}
