extension Markdown
{
    final
    class BlockImage:BlockLeaf
    {
        /// Not to be confused with ``source``.
        private(set)
        var src:String?
        private(set)
        var alt:String?

        override
        init()
        {
            self.src = nil
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
            guard case nil = self.src
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.src = value

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
