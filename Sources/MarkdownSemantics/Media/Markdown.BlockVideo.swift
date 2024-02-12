extension Markdown
{
    final
    class BlockVideo:BlockLeaf
    {
        private(set)
        var poster:String?
        /// Not to be confused with ``source``.
        private(set)
        var src:String?
        private(set)
        var alt:String?

        override
        init()
        {
            self.poster = nil
            self.src = nil
            self.alt = nil
            super.init()
        }
    }
}
extension Markdown.BlockVideo:Markdown.BlockDirectiveType
{
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "poster":
            guard case nil = self.poster
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.poster = value

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
