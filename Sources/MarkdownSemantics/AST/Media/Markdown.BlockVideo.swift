import Sources

extension Markdown
{
    final
    class BlockVideo:BlockContainer<BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        private(set)
        var poster:String?
        /// Not to be confused with ``source``.
        private(set)
        var src:String?
        private(set)
        var alt:String?

        init()
        {
            self.source = nil
            self.poster = nil
            self.src = nil
            self.alt = nil
            super.init([])
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.figure]
            {
                //  $0[.video, { $0[.poster] = self.poster }]
                $0[.video]
                {
                    // `<video>` does not support alt text.
                    $0[.source]
                    {
                        $0[.src] = self.src
                        // $0[.alt] = self.alt
                    }
                }

                if  self.elements.isEmpty
                {
                    return
                }

                $0[.figcaption]
                {
                    super.emit(into: &$0)
                }
            }
        }
    }
}
extension Markdown.BlockVideo:Markdown.BlockDirectiveType
{
    func configure(option:String, value:String, from _:SourceReference<Markdown.Source>) throws
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

        case "src", "source":
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
