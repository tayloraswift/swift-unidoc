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

        init(size:Int?)
        {
            self.source = nil
            self.size = size
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
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "size":
            guard
            let size:Int = .init(value)
            else
            {
                throw ArgumentError.size(value)
            }
            //  This is checked differently, because sometimes ``size`` gets a default value.
            if  let previous:Int = self.size,
                    previous != size
            {
                throw ArgumentError.duplicated(option)
            }

            self.size = size

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
