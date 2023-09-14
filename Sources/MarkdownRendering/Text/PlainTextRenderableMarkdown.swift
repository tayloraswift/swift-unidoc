import MarkdownABI

public
protocol PlainTextRenderableMarkdown:TextOutputStreamable, CustomStringConvertible
{
    var bytecode:MarkdownBytecode { get }

    /// Writes arbitrary content to the provided UTF-8 output, identified by
    /// the given reference.
    func load(_ reference:Int, into utf8:inout [UInt8])
}
extension PlainTextRenderableMarkdown
{
    /// Does nothing.
    @inlinable public
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
    }
}
extension PlainTextRenderableMarkdown
{
    @inlinable public
    func write(to stream:inout some TextOutputStream)
    {
        stream.write(self.description)
    }
}
extension PlainTextRenderableMarkdown
{
    public
    var description:String
    {
        do
        {
            var utf8:[UInt8] = []
            try self.write(to: &utf8)
            return .init(decoding: utf8, as: Unicode.UTF8.self)
        }
        catch let error
        {
            return "<\(error)>"
        }
    }

    public
    func write(to utf8:inout [UInt8]) throws
    {
        var attributes:MarkdownTextContext.AttributeContext = .init()
        var stack:[MarkdownTextContext] = []

        for instruction:MarkdownInstruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw MarkdownRenderingError.invalidInstruction

            case .attribute(let attribute, nil):
                attributes.flush(beginning: attribute)

            case .attribute(_, _?):
                attributes.flush()

            case .emit(_):
                attributes.clear()

            case .load(let reference):
                attributes.clear()
                self.load(reference, into: &utf8)

            case .push(let element):
                attributes.clear()
                stack.append(.init(from: element))

            case .pop:
                attributes.clear()

                guard case _? = stack.popLast()
                else
                {
                    throw MarkdownRenderingError.illegalInstruction
                }

            case .utf8(let codeunit):
                if  case nil = attributes.buffer(utf8: codeunit),
                    case .visible = stack.last ?? .visible
                {
                    utf8.append(codeunit)
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
