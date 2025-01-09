import Sources

extension Markdown
{
    final
    class BlockVideo:BlockContainer<BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        private(set)
        var poster:Outlinable<SourceString>?
        /// Not to be confused with ``source``.
        private(set)
        var src:Outlinable<SourceString>?
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
                if  case (nil, nil) = (self.poster, self.src)
                {
                    return
                }

                $0[.video]
                {
                    //  if  case .outlined(let reference) = self.poster
                    //  {
                    //      $0[.poster] = reference
                    //  }

                    // `<video>` does not support alt text.
                    $0[.source] { $0[.src] = self.src }
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

        override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            if  case .inline(let expression) = self.poster,
                case let reference? = try register(.file(expression))
            {
                self.poster = .outlined(reference)
            }

            if  case .inline(let expression) = self.src,
                case let reference? = try register(.file(expression))
            {
                self.src = .outlined(reference)
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockVideo:Markdown.BlockDirectiveType
{
    enum Option:String, Markdown.BlockDirectiveOption
    {
        case poster
        case src, source
        case alt
    }

    func configure(option:Option, value:Markdown.SourceString) throws
    {
        switch option
        {
        case .poster:
            guard case nil = self.poster
            else
            {
                throw option.duplicate
            }

            self.poster = .inline(value)

        case .src, .source:
            guard case nil = self.src
            else
            {
                throw option.duplicate
            }

            self.src = .inline(value)

        case .alt:
            guard case nil = self.alt
            else
            {
                throw option.duplicate
            }

            self.alt = value.string
        }
    }
}
