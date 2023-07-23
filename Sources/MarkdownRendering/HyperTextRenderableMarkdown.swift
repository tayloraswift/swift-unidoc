import HTML
import MarkdownABI

public
protocol HyperTextRenderableMarkdown:HyperTextOutputStreamable
{
    var bytecode:MarkdownBytecode { get }

    /// Returns the value for an attribute identified by the given reference.
    /// If the witness returns nil, the renderer will omit the attribute.
    ///
    /// This can be used to influence the behavior of the special syntax
    /// highlight contexts.
    func load(_ reference:Int, for attribute:MarkdownBytecode.Attribute) -> String?

    /// Writes arbitrary content to the provided HTML output, identified by
    /// the given reference.
    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
}
extension HyperTextRenderableMarkdown
{
    /// Returns nil.
    @inlinable public
    func load(_ reference:Int, for attribute:MarkdownBytecode.Attribute) -> String?
    {
        nil
    }
    /// Does nothing.
    @inlinable public
    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
    }
}
extension HyperTextRenderableMarkdown
{
    /// Equivalent to ``render(to:)``, but ignores all errors.
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        do { try self.render(to: &html) } catch { }
    }

    /// Runs this markdown executable and renders its output to the HTML argument.
    /// If an error occurs, stops execution and throws the error, otherwise
    /// returns nil if successful. This function always closes any HTML elements
    /// it creates, even on error.
    public
    func render(to html:inout HTML.ContentEncoder) throws
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

        var newlines:Int = 0
        for instruction:MarkdownInstruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw MarkdownRenderingError.invalidInstruction

            case .attribute(let attribute, nil):
                attributes.commit()
                attributes.current = (attribute, [])


            case .attribute(let attribute, let reference?):
                attributes.commit()

                if  let value:String = self.load(reference, for: attribute)
                {
                    attributes.append(value: value, as: attribute)
                }

            case .emit(let element):
                attributes.commit()

                html.emit(newlines: &newlines)
                html.emit(element: element, with: attributes)

                attributes.clear()

            case .load(let reference):
                attributes.clear()
                self.load(reference, into: &html)

            case .push(let element):
                attributes.commit()

                let context:MarkdownElementContext = .init(from: element,
                    attributes: &attributes)

                html.emit(newlines: &newlines)
                html.open(context: context, with: attributes)

                attributes.clear()
                stack.append(context)

            case .pop:
                attributes.clear()

                switch stack.popLast()
                {
                case .snippet?:
                    newlines = 0
                    html.close(context: .snippet)

                case let context?:
                    html.close(context: context)

                case nil:
                    throw MarkdownRenderingError.illegalInstruction
                }

            case .utf8(let codeunit):
                guard case nil = attributes.current?.utf8.append(codeunit)
                else
                {
                    continue
                }
                //  Not in an attribute context.
                switch stack.last
                {
                case .transparent?:
                    html.append(escaped: codeunit)

                case .snippet?:
                    if  codeunit == 0x0A // '\n'
                    {
                        newlines += 1
                    }
                    else
                    {
                        html.emit(newlines: &newlines)
                        fallthrough
                    }

                case _:
                    html.append(unescaped: codeunit)
                }
            }
        }
        guard stack.isEmpty
        else
        {
            throw MarkdownRenderingError.interrupted
        }
    }
}
