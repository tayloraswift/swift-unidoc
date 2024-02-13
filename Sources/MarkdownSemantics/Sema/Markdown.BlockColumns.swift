import Sources

extension Markdown
{
    final
    class BlockColumns:Markdown.BlockContainer<Markdown.BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        private(set)
        var count:Int?

        init()
        {
            self.source = nil
            self.count = nil
            super.init([])
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.div]
            {
                //  Let’s not encode that long string if we can help it.
                $0[.class] = "columns"
                $0[.style] = self.count.map { "grid-template-columns: repeat(\($0), 1fr);" }
            }
                content:
            {
                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockColumns:Markdown.BlockDirectiveType
{
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "numberOfColumns":
            guard case nil = self.count
            else
            {
                throw ArgumentError.duplicated(option)
            }
            guard
            let count:Int = .init(value)
            else
            {
                throw ArgumentError.count(value)
            }

            self.count = count

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
