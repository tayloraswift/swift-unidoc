import HTML
import MarkdownABI

extension HTML
{
    public
    typealias OutputStreamableMarkdown = _HTMLOutputStreamableMarkdown
}

@available(*, deprecated, renamed: "HTML.OutputStreamableMarkdown")
public
typealias HyperTextRenderableMarkdown = HTML.OutputStreamableMarkdown

/// The name of this protocol is ``HTML.OutputStreamableMarkdown``.
public
protocol _HTMLOutputStreamableMarkdown:HTML.OutputStreamable
{
    var bytecode:Markdown.Bytecode { get }

    /// Returns the value for an attribute identified by the given reference.
    /// If the witness returns nil, the renderer will omit the attribute.
    ///
    /// The witness can change the attribute that will be rendered by modifying the argument.
    /// This is useful for replacing ``Markdown.Bytecode.Attribute/href`` with
    /// ``Markdown.Bytecode.Attribute/external``
    ///
    /// This can be used to influence the behavior of the special syntax
    /// highlight contexts.
    func load(_ reference:Int, for attribute:inout Markdown.Bytecode.Attribute) -> String?

    /// Writes arbitrary content to the provided HTML output, identified by
    /// the given reference.
    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
}
extension HTML.OutputStreamableMarkdown
{
    /// Returns nil.
    @inlinable public
    func load(_ reference:Int, for attribute:inout Markdown.Bytecode.Attribute) -> String?
    {
        nil
    }
    /// Does nothing.
    @inlinable public
    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
    }
}
extension HTML.OutputStreamableMarkdown
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
    ///
    /// See ``TextOutputStreamableMarkdown.write(to:)`` for a simpler version of this function
    /// that only renders visible text.
    public
    func render(to html:inout HTML.ContentEncoder) throws
    {
        var attributes:Markdown.TreeContext.AttributeContext = .init()
        var stack:[Markdown.TreeContext] = []

        defer
        {
            for context:Markdown.TreeContext in stack.reversed()
            {
                html.close(context: context)
            }
        }

        var newlines:Int = 0
        for instruction:Markdown.Instruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw Markdown.RenderingError.invalidInstruction

            case .attribute(let attribute, nil):
                attributes.flush(beginning: attribute)

            case .attribute(var attribute, let reference?):
                attributes.flush()

                if  let value:String = self.load(reference, for: &attribute)
                {
                    attributes.list.append(value: value, as: attribute)
                }

            case .emit(let element):
                attributes.flush()

                html.emit(newlines: &newlines)
                html.emit(element: element, with: attributes.list)

                attributes.clear()

            case .load(let reference):
                attributes.clear()
                self.load(reference, into: &html)

            case .push(let element):
                attributes.flush()

                let context:Markdown.TreeContext = .init(from: element,
                    attributes: &attributes.list)

                html.emit(newlines: &newlines)
                html.open(context: context, with: attributes.list)

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
                    throw Markdown.RenderingError.illegalInstruction
                }

            case .utf8(let codeunit):
                guard case nil = attributes.buffer(utf8: codeunit)
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
            throw Markdown.RenderingError.interrupted
        }
    }
}
