import HTML

@rethrows public
protocol MarkdownExecutable
{
    var bytecode:MarkdownBytecode { get }

    /// Returns the value for an attribute identified by the given reference.
    /// If the witness returns nil, the renderer will omit the attribute.
    func load(_ reference:UInt32) throws -> String?

    /// Writes arbitrary content to the provided HTML output, identified by
    /// the given reference.
    func load(_ reference:UInt32, into html:inout HTML) throws
}
extension MarkdownExecutable
{
    /// Returns nil.
    public
    func load(_ reference:UInt32) -> String?
    {
        nil
    }
    /// Renders a placeholder `code` element describing the reference.
    public
    func load(_ reference:UInt32, into html:inout HTML)
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
            
            case .attribute(let attribute, nil):
                attributes.commit()
                attributes.current = (attribute, [])
            
            
            case .attribute(let attribute, let reference?):
                attributes.commit()

                if  let value:String = try self.load(reference)
                {
                    attributes.append(value: value, as: attribute)
                }
            
            case .emit(let element):
                attributes.commit()
                html.emit(element: element, with: attributes)
                attributes.clear()
            
            case .load(let reference):
                attributes.clear()
                try self.load(reference, into: &html)
            
            case .push(let element):
                attributes.commit()

                let context:MarkdownElementContext = .init(from: element,
                    attributes: &attributes)
                
                html.open(context: context, with: attributes)

                attributes.clear()
                stack.append(context)
            
            case .pop:
                attributes.clear()

                if let context:MarkdownElementContext = stack.popLast()
                {
                    html.close(context: context)
                }
                else
                {
                    return .illegal
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
        return stack.isEmpty ? nil : .incomplete
    }
}
