extension Markdown
{
    final
    class BlockVideo:BlockLeaf
    {
        private(set)
        var poster:String?
        private(set)
        var source:String?
        private(set)
        var alt:String?

        override
        init()
        {
            self.poster = nil
            self.source = nil
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
