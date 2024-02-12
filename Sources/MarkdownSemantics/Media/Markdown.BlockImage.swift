extension Markdown
{
    final
    class BlockImage:BlockLeaf
    {
        private(set)
        var source:String?
        private(set)
        var alt:String?

        override
        init()
        {
            self.source = nil
            self.alt = nil
            super.init()
        }
    }
}
extension Markdown.BlockImage:Markdown.BlockDirectiveType
{
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "source":
            guard case nil = self.source
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.source = value

        case "alt":
            guard case nil = self.alt
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.alt = value

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
