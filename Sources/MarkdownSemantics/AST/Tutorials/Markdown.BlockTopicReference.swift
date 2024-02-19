import MarkdownABI
import Doclinks
import Sources

extension Markdown
{
    final
    class BlockTopicReference:Markdown.BlockLeaf
    {
        var target:Outlinable<SourceString>?

        override
        init()
        {
            self.target = nil
            super.init()
        }

        override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            if  case .inline(let expression) = self.target,
                case let reference? = try register(.link(expression))
            {
                self.target = .outlined(reference)
            }
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            guard
            let target:Outlinable<SourceString> = self.target
            else
            {
                return
            }

            binary[.ul]
            {
                switch target
                {
                case .inline(let link):
                    $0[.li] { $0[.code] = link.string }

                case .outlined(let reference):
                    $0[.li] { $0 &= reference }
                }
            }
        }
    }
}
extension Markdown.BlockTopicReference:Markdown.BlockDirectiveType
{
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "tutorial":
            guard case nil = self.target
            else
            {
                throw ArgumentError.duplicate(option)
            }
            guard
            let doclink:Doclink = .init(value.string)
            else
            {
                throw ArgumentError.doclink(value.string)
            }

            self.target = .inline(.init(source: value.source, string: doclink.text))

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
