import MarkdownAST
import Sources

extension Markdown
{
    final
    class BlockDivision:Markdown.BlockContainer<Markdown.BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        private(set)
        var size:Int?

        init()
        {
            self.source = nil
            self.size = nil
            super.init([])
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.div]
            {
                $0[.style] = self.size.map { "grid-column: span \($0);" }
            }
                content:
            {
                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockDivision:Markdown.BlockDirectiveType
{
    public final
    func configure(option:String, value:String, from _:SourceReference<Markdown.Source>) throws
    {
        switch option
        {
        case "size":
            guard case nil = self.size
            else
            {
                throw ArgumentError.duplicated(option)
            }
            guard
            let size:Int = .init(value)
            else
            {
                throw ArgumentError.size(value)
            }

            self.size = size

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
