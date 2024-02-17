import MarkdownABI
import Doclinks
import Sources

extension Markdown
{
    final
    class BlockTopicReference:Markdown.BlockLeaf
    {
        var target:Target?

        override
        init()
        {
            self.target = nil
            super.init()
        }

        override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            if  case let .unresolved(autolink) = self.target,
                case let reference? = try register(autolink)
            {
                self.target = .resolved(reference)
            }
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            guard
            let target:Target = self.target
            else
            {
                return
            }

            binary[.ul]
            {
                switch target
                {
                case .unresolved(let autolink):
                    $0[.li] { $0[.code] = autolink.text }
                case .resolved(let reference):
                    $0[.li] { $0 &= reference }
                }
            }
        }
    }
}
extension Markdown.BlockTopicReference:Markdown.BlockDirectiveType
{
    func configure(option:String,
        value:String,
        from source:SourceReference<Markdown.Source>) throws
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
            let doclink:Doclink = .init(value)
            else
            {
                throw ArgumentError.doclink(value)
            }

            self.target = .unresolved(.init(source: source,
                text: doclink.text,
                code: false))

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
