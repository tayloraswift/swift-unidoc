import MarkdownABI
import MarkdownAST
import MarkdownDisplay

extension Markdown
{
    public final
    class BlockCard:BlockElement
    {
        public
        var target:Outlinable<InlineAutolink>

        init(target:InlineAutolink)
        {
            self.target = .inline(target)
        }

        @inlinable public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            switch self.target
            {
            case .outlined(let reference):
                binary &= .card(reference)

            case .inline(let autolink):
                binary[.code] = autolink.text.string
            }
        }

        @inlinable public override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            if  case .inline(let autolink) = self.target,
                case let reference? = try register(.init(autolink))
            {
                self.target = .outlined(reference)
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockCard
{
    convenience
    init?(from item:inout [Markdown.BlockElement])
    {
        if  item.count == 1,
            case let paragraph as Markdown.BlockParagraph = item[0],
            paragraph.elements.count == 1,
            case .autolink(let autolink) = paragraph.elements[0]
        {
            self.init(target: autolink)
            item[0] = self
        }
        else
        {
            return nil
        }
    }
}
