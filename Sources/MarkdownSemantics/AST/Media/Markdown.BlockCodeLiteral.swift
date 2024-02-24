import MarkdownABI
import Sources

extension Markdown
{
    /// A `BlockCodeLiteral` is like a ``BlockCode``, but it contains code that has already been
    /// highlighted and compiled to bytecode.
    final
    class BlockCodeLiteral:BlockElement
    {
        private
        let bytecode:Markdown.Bytecode
        private
        let language:String

        private
        var location:Outlinable<SourceLocation<Int32>>?

        init(bytecode:Markdown.Bytecode,
            language:String = "swift",
            location:SourceLocation<Int32>?)
        {
            self.bytecode = bytecode
            self.language = language
            self.location = location.map(Outlinable.inline(_:))
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.snippet, { $0[.language] = self.language }]
            {
                $0 += self.bytecode
            }
            if  case .outlined(let reference) = self.location
            {
                binary &= reference
            }
        }

        override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            if  case .inline(let location) = self.location,
                let reference:Int = try register(.location(location))
            {
                self.location = .outlined(reference)
            }

            try super.outline(by: register)
        }
    }
}
