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
            //  https://stackoverflow.com/questions/43311943/prevent-content-from-expanding-grid-items
            binary[.div]
            {
                $0[.class] = "columns"
                $0[.style] = """
                grid-template-columns: repeat(\(self.count ?? self.elements.count), minmax(0, 1fr));
                """
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
    enum Option:String, Markdown.BlockDirectiveOption
    {
        case numberOfColumns
    }

    func configure(option:Option, value:Markdown.SourceString) throws
    {
        switch option
        {
        case .numberOfColumns:
            guard case nil = self.count
            else
            {
                throw option.duplicate
            }

            self.count = try option.cast(value, to: Int.self)
        }
    }
}
