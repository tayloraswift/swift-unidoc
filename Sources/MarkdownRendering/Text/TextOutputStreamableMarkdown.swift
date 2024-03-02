import MarkdownABI

public
protocol TextOutputStreamableMarkdown:TextOutputStreamable, CustomStringConvertible
{
    var bytecode:Markdown.Bytecode { get }

    /// Writes arbitrary content to the provided UTF-8 output, identified by
    /// the given reference.
    func load(_ reference:Int, into utf8:inout [UInt8])

    /// Do something with the given reference. For example, this can be used to change the
    /// behavior of a subsequent ``load(_:into:)`` call.
    func call(_ reference:Int)
}
extension TextOutputStreamableMarkdown
{
    /// Does nothing.
    @inlinable public
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
    }
}
extension TextOutputStreamableMarkdown
{
    @inlinable public
    func write(to stream:inout some TextOutputStream)
    {
        stream.write(self.description)
    }
}
extension TextOutputStreamableMarkdown
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
        var attributes:Markdown.TextContext.AttributeContext = .init()
        var stack:[Markdown.TextContext] = []

        var call:Bool = false

        for instruction:Markdown.Instruction in self.bytecode
        {
            switch instruction
            {
            case .invalid:
                throw Markdown.RenderingError.invalidInstruction

            case .attribute(let attribute, nil):
                attributes.flush(beginning: attribute)

            case .attribute(_, _?):
                attributes.flush()

            case .call:
                call = true

            case .emit(_):
                attributes.clear()

            case .load(let reference):
                attributes.clear()

                if  call
                {
                    call = false
                    self.call(reference)
                }
                else
                {
                    self.load(reference, into: &utf8)
                }

            case .push(let element):
                attributes.clear()
                stack.append(.init(from: element))

            case .pop:
                attributes.clear()

                guard case _? = stack.popLast()
                else
                {
                    throw Markdown.RenderingError.illegalInstruction
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
            throw Markdown.RenderingError.interrupted
        }
    }
}
