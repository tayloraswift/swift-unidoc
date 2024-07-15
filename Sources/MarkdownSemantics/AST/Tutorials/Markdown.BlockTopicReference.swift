import MarkdownABI
import MarkdownDisplay
import Sources
import UCF

extension Markdown
{
    final
    class BlockTopicReference:Markdown.BlockLeaf
    {
        var targets:[Outlinable<SourceString>]

        override
        init()
        {
            self.targets = []
            super.init()
        }

        override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            for i:Int in self.targets.indices
            {
                try
                {
                    if  case .inline(let expression) = $0,
                        case let reference? = try register(.link(url: expression))
                    {
                        $0 = .outlined(reference)
                    }
                } (&self.targets[i])
            }
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            if  self.targets.isEmpty
            {
                return
            }

            binary[.ul, { $0[.class] = "cards" }]
            {
                for target:Outlinable<SourceString> in self.targets
                {
                    switch target
                    {
                    case .outlined(let reference):
                        $0[.li] { $0 &= .card(reference) }

                    case .inline(let link):
                        $0[.li] { $0[.code] = link.string }
                    }
                }
            }
        }
    }
}
extension Markdown.BlockTopicReference:Markdown.BlockDirectiveType
{
    func configure(option:String, value:Markdown.SourceString) throws
    {
        //  Yes, this technically means the block directive can accept more than one `tutorial`
        //  argument. This makes it easier to accumulate multiple consecutive instances of this
        //  directive into a single topic list.
        switch option
        {
        case "tutorial":
            guard
            let doclink:Doclink = .init(value.string)
            else
            {
                throw ArgumentError.doclink(value.string)
            }

            self.targets.append(.inline(.init(source: value.source, string: doclink.text)))

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
